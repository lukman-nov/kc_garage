local ESX = nil

local vehicleClassName = {
  [0] = 'Compacts',
  [1] = 'Sedans',
  [2] = 'SUVs',
  [3] = 'Coupes',
  [4] = 'Muscle',
  [5] = 'Sports Classics',
  [6] = 'Sports',
  [7] = 'Super',
  [8] = 'Motorcycles',
  [9] = 'Off-road',
  [10] = 'Industrial',
  [11] = 'Utility', 
  [12] = 'Vans',
  [13] = 'Cylces',
  [14] = 'Boats',
  [15] = 'Helicopters',
  [16] = 'Planes',
  [17] = 'Service',
  [18] = 'Emergency',
  [19] = 'Military',
  [20] = 'Commercial',
  [21] = 'Train'
}

local entityEnumerator = {
	__gc = function(enum)
    if enum.destructor and enum.handle then
		  enum.destructor(enum.handle)
	  end
    enum.destructor = nil
    enum.handle = nil
  end
}

CreateThread(function()
	while ESX == nil do
		ESX = exports["es_extended"]:getSharedObject()
		Wait(10)
	end 
  
	while ESX.GetPlayerData().job == nil and ESX.GetPlayerData() == nil do
		Citizen.Wait(10)
	end
	ESX.PlayerData = ESX.GetPlayerData()
end)

CreateThread(function()
  for _, v in pairs(Config.Garages) do
    if v.Blip then
      local blip = AddBlipForCoord(v.Coords)
      if v.Type == 'aircraft' then
        SetBlipSprite(blip, 359)
        SetBlipColour(blip, 3)
        SetBlipDisplay(blip, 2)
        SetBlipScale(blip, 0.8)
      elseif v.Type == 'car' then
        SetBlipSprite(blip, 357)
        SetBlipColour(blip, 3)
        SetBlipDisplay(blip, 2)
        SetBlipScale(blip, 0.8)
      elseif v.Type == 'boat' then
        SetBlipSprite(blip, 356)
        SetBlipColour(blip, 3)
        SetBlipDisplay(blip, 2)
        SetBlipScale(blip, 0.8)
      end
      SetBlipAsShortRange(blip, true)
      BeginTextCommandSetBlipName('STRING')
      AddTextComponentSubstringPlayerName(_K('garage', v.Label))
      EndTextCommandSetBlipName(blip)
    end
    SpawnNpc(v.Coords, v.PedHeading, Config.Peds.Garages)
  end

  for _, v in pairs(Config.Impound) do
    if v.Blip then
      local blip = AddBlipForCoord(v.Coords)
      if v.Type == 'aircraft' then
        SetBlipSprite(blip, 359)
        SetBlipColour(blip, 51)
        SetBlipDisplay(blip, 2)
        SetBlipScale(blip, 0.8)
      elseif v.Type == 'car' then
        SetBlipSprite(blip, 477)
        SetBlipColour(blip, 51)
        SetBlipDisplay(blip, 2)
        SetBlipScale(blip, 0.7)
      elseif v.Type == 'boat' then
        SetBlipSprite(blip, 356)
        SetBlipColour(blip, 51)
        SetBlipDisplay(blip, 2)
        SetBlipScale(blip, 0.8)
      end
      SetBlipAsShortRange(blip, true)
      BeginTextCommandSetBlipName('STRING')
      AddTextComponentSubstringPlayerName(_K('impound', v.Label))
      EndTextCommandSetBlipName(blip)
    end
    SpawnNpc(v.Coords, v.PedHeading, Config.Peds.Impound)
  end
end)

CreateThread(function()
  if Config.UseTarget then
    exports.ox_target:addModel(Config.Peds.Garages, {
      {
        name = 'getVehGarage',
        icon = 'fa-solid fa-car',
        label = _K('get_veh_list'),
        onSelect = function(data)
          for garageName, Garage in pairs(Config.Garages) do
            if #(data.coords - Garage.Coords) < 2.0 then
              data.type = 'Garages'
              data.vehType = Garage.Type
              TriggerEvent('kc_garage:getVehList', data)
            end
          end
        end,
        canInteract = function(entity, distance, coords, name, bone)
          for garageName, Garage in pairs(Config.Garages) do
            if #(coords - Garage.Coords) < 2.0 then 
              if distance < 2.0 and HasPlayers(garageName) and HasGroups(garageName) then return true end
            end
          end
          
        end
      },
    })
    
    exports.ox_target:addModel(Config.Peds.Impound, {
      {
        name = 'getVehImpound',
        icon = 'fa-solid fa-car',
        label = _K('get_veh_list'),
        onSelect = function(data)
          for ImpoundName, Impound in pairs(Config.Impound) do
            if #(data.coords - Impound.Coords) < 2.0 then
              data.type = 'Impound'
              data.vehType = Impound.Type
              TriggerEvent('kc_garage:getVehList', data)
            end
          end
        end,
        canInteract = function(entity, distance, coords, name, bone)
          if distance < 2.0 then return true end
        end
      },
    })

    exports.ox_target:addGlobalVehicle({
      {
        name = 'storedVeh',
        icon = 'fa-solid fa-square-parking',
        label = _K('parking'),
        onSelect = function(target)
          TriggerEvent('kc_garage:saveVehicles', GetGarageName(target.coords, 'key', 'Garages'), target.entity)
        end,
        canInteract = function(entity, distance, coords, name, bone)
          for garageName, Garage in pairs(Config.Garages) do
            for i = 1, #Garage.DeletePoint do
              if #(coords - Garage.DeletePoint[i].Pos) < 2.0 and HasPlayers(garageName) and HasGroups(garageName) then return true end
            end
          end
        end
      }
    })
  else
    for garageName, Garage in pairs(Config.Garages) do
      garages = lib.points.new(Garage.Coords, 3.0, {
        type = 'Garages',
        vehType = Garage.Type
      })
      function garages:nearby()
        lib.showTextUI(_K('press_get_veh'),{
          position = "right-center",
          icon = 'warehouse',
            style = {
            borderRadius = 5,
            backgroundColor = '#4ba9ff',
            color = 'white'
          }
        })
        if IsControlJustReleased(0, 38) then
          TriggerEvent('kc_garage:getVehList', self, self.coords)
        end
      end
      function garages:onExit()
        lib.hideTextUI()
      end
      
      for i = 1, #Garage.DeletePoint, 1 do
        invehGarages = lib.points.new(Garage.DeletePoint[i].Pos, 10)
        function invehGarages:nearby()
          if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
            DrawMarker(36, self.coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 100, 100, 100, false, true, 2, true, false, false, false)   
            if self.currentDistance < 2.0 then
              local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
              if IsControlJustReleased(0, 38) then
                TriggerEvent('kc_garage:saveVehicles', GetGarageName(self.coords, 'key', 'Garages'), vehicle)
              end
            end
          end
        end
      end
    end
    function invehGarages:onExit()
      lib.hideTextUI()
    end
    
    for _, Impound in pairs(Config.Impound) do
      impounds = lib.points.new(Impound.Coords, 3.0)
      function impounds:nearby()
        lib.showTextUI(_K('press_get_veh'),{
          position = "right-center",
          icon = 'warehouse',
          style = {
            borderRadius = 5,
            backgroundColor = '#4ba9ff',
            color = 'white'
          }
        })
        if IsControlJustReleased(0, 38) then
          TriggerEvent('kc_garage:getVehList', 'Impound', self.coords)
          lib.hideTextUI()
        end
      end
      function impounds:onExit()
        lib.hideTextUI()
      end
    end
  end
end)

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(job)
  ESX.PlayerData.job = job
end)

RegisterNetEvent('kc_garage:notify')
AddEventHandler('kc_garage:notify', function(_type, args)
  if Config.Notify == 'mythic_notify' then
    exports['mythic_notify']:DoHudText(_type, args)
  elseif Config.Notify == 'lib' then
    lib.notify({
      description = args,
      type = _type
    })
  elseif Config.Notify == 'ESX' then
    ESX.ShowNotification(args)
  end
end)

RegisterNetEvent('kc_garage:getVehList')
AddEventHandler('kc_garage:getVehList', function(data, playerCoords)
  local stored = 1
  local icons = 'car-side'
  
  if not playerCoords then
    playerCoords = data.coords
  end

  if data.type == 'Impound' then
    stored = 0
  end

  ESX.TriggerServerCallback('kc_garage:getVehiclesInParking', function(vehicles)
    local vehiclesTableList = {}
    if vehicles then
      for i = 1, #vehicles, 1 do
        if vehicles[i].vehType == Config[data.type][vehicles[i].parking].Type and vehicles[i].vehType == data.vehType then
          local engineHealth = vehicles[i].vehicle.engineHealth * 100 / 1000
          local bodyHealth = vehicles[i].vehicle.bodyHealth * 100 / 1000
          if #(playerCoords - Config[data.type][vehicles[i].parking].Coords) < 3.0 then
            vehiclesTableList[GetDisplayNameFromVehicleModel(vehicles[i].vehicle.model)] = {
              description = _K('engine')..engineHealth..'% | '.._K('body')..bodyHealth..'% | '.._K('fuel')..vehicles[i].vehicle.fuelLevel.. '%',
              event = 'kc_garage:spawnVehicle',
              icon = GetIcons(vehicleClassName[GetVehicleClassFromName(vehicles[i].vehicle.model)]),
              args = {
                type = data.type,
                parking = vehicles[i].parking,
                vehicle = vehicles[i].vehicle,
              },
              metadata = {
                [_K('parking')] = Config[data.type][vehicles[i].parking].Label, 
                [_K('plate')] = vehicles[i].plate,
                [_K('fee')] = Config.VehicleFee[data.type][GetVehicleClassFromName(vehicles[i].vehicle.model)],
                [_K('type')] = vehicleClassName[GetVehicleClassFromName(vehicles[i].vehicle.model)]
              }
            }
            ParkingName = Config[data.type][vehicles[i].parking].Label
          end
        end
      end
      lib.registerContext({
        id = 'garage_menu',
        title = GetGarageName(playerCoords, 'label', data.type).. ' ' ..data.type,
        options = vehiclesTableList
      })
      lib.showContext('garage_menu')
    end
  end, stored)
end)

RegisterNetEvent('kc_garage:spawnVehicle')
AddEventHandler('kc_garage:spawnVehicle', function(data)
  WaitForVehicleToLoad(data.vehicle.model)
  local price = Config.VehicleFee[data.type][GetVehicleClassFromName(data.vehicle.model)]
  local foundSpawn, SpawnPoint = GetAvailableVehicleSpawnPoint(Config[data.type][data.parking].SpawnPoint)
  if foundSpawn then
    ESX.TriggerServerCallback('kc_garage:checkMoney', function(playerMoney)
      if playerMoney >= price then

        if Config[data.type][data.parking].Pay then
          TriggerServerEvent('kc_garage:removeMoney', price)
        end
        
        ESX.Game.SpawnVehicle(data.vehicle.model, SpawnPoint.Pos, SpawnPoint.Heading, function(vehicle)
          ESX.Game.SetVehicleProperties(vehicle, data.vehicle)
          
          if Config.TeleportToVehicle or Config[data.type][data.parking].Type == 'boat' then
            TaskWarpPedIntoVehicle(GetPlayerPed(-1), vehicle, -1)
            SetVehicleEngineOn(vehicle, true, true)
          end

          local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
          TriggerServerEvent('kc_garage:updateOwnedVehicle', 0, nil, vehicleProps)
          
          if Config.AutoLockVeh then
            SetVehicleDoorsLocked(vehicle, 2)
          end
          
          TriggerEvent('kc_garage:notify', 'success', _K('veh_spawn'))
        end)
      else
        TriggerEvent('kc_garage:notify', 'error', _K('not_money'))
      end
    end, data.type)
  end
end)

RegisterNetEvent('kc_garage:saveVehicles')
AddEventHandler('kc_garage:saveVehicles', function(garageName, vehicle)
  local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
  ESX.TriggerServerCallback('kc_garage:checkVehicleOwner', function(owner)
    if owner then 
      if not Config.UseTarget then
        TaskLeaveVehicle(GetPlayerPed(-1), vehicle, 1)
        Wait(2000)
      end
      DeleteVehicle(vehicle)
      TriggerServerEvent('kc_garage:updateOwnedVehicle', 1, garageName, vehicleProps)
    else
      TriggerEvent('kc_garage:notify', 'error', _K('not_yours_veh'))
    end
  end, vehicleProps.plate)
end)

RegisterNetEvent('kc_garage:vehLockedEffect')
AddEventHandler('kc_garage:vehLockedEffect', function(netId, lockStatus)
  local vehicle = NetToVeh(netId)
  if DoesEntityExist(vehicle) then
    local ped = PlayerPedId()

    local prop = GetHashKey('p_car_keys_01')
    RequestModel(prop)
    while not HasModelLoaded(prop) do
        Citizen.Wait(10)
    end
    local keyObj = CreateObject(prop, 1.0, 1.0, 1.0, 1, 1, 0)
    AttachEntityToEntity(keyObj, ped, GetPedBoneIndex(ped, 57005), 0.08, 0.039, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    local dict = "anim@mp_player_intmenu@key_fob@"

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
      Citizen.Wait(0)
    end

    if not IsPedInAnyVehicle(PlayerPedId(), true) then
      TaskPlayAnim(ped, dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
    end

    PlayVehicleDoorOpenSound(vehicle, 1)
    SetVehicleDoorsLockedForAllPlayers(vehicle, lockStatus)
    if lockStatus then
      TriggerEvent('kc_garage:notify', 'inform', _K('veh_locked'))
    else
      TriggerEvent('kc_garage:notify', 'inform', _K('veh_unlocked'))
    end
    SetVehicleLights(vehicle, 2)
    StartVehicleHorn(vehicle, 50, 'HELDDOWN', false)
    Citizen.Wait(250)
    StartVehicleHorn(vehicle, 50, 'HELDDOWN', false)
    SetVehicleLights(vehicle, 0)
    Citizen.Wait(250)
    SetVehicleLights(vehicle, 2)
    Citizen.Wait(250)
    SetVehicleLights(vehicle, 0)
    Wait(600)
    DetachEntity(keyObj, false, false)
    DeleteEntity(keyObj)
  end
end)

RegisterNetEvent("kc_garage:deleteVehicle")
AddEventHandler("kc_garage:deleteVehicle", function()
	local minuteCalculation = 6000
	local minutesPassed = 0
	local minutesLeft = Config.DeleteVehicleTimer

	TriggerEvent('kc_garage:notify', 'warning', _K('del_veh_msg', minutesLeft))

	while minutesPassed < Config.DeleteVehicleTimer do
		Citizen.Wait(1*minuteCalculation)
		minutesPassed = minutesPassed + 1
		minutesLeft = minutesLeft - 1
		if minutesLeft == 0 then
			TriggerEvent('kc_garage:notify', 'inform', _K('del_veh_end'))
		elseif minutesLeft == 1 then
			TriggerEvent('kc_garage:notify', 'inform', _K('del_veh_msg', minutesLeft))
		else
			TriggerEvent('kc_garage:notify', 'inform', _K('del_veh_msg', minutesLeft))
		end
	end

	for vehicle in EnumerateVehicles() do
		local canDelete = true
		local carCoords = GetEntityCoords(vehicle)

		if (not IsPedAPlayer(GetPedInVehicleSeat(vehicle, -1))) then
			if not Config.DeleteVehiclesIfInSafeZone then
				for i = 1, #Config.SafeZones, 1 do
					dist = Vdist(Config.SafeZones[i].x, Config.SafeZones[i].y, Config.SafeZones[i].z, carCoords.x, carCoords.y, carCoords.z)
					if dist < Config.SafeZones[i].radius then
						canDelete = false
					end
				end
			end
			if canDelete then
				SetVehicleHasBeenOwnedByPlayer(vehicle, false) 
				SetEntityAsMissionEntity(vehicle, false, false)
				DeleteVehicle(vehicle)
				if (DoesEntityExist(vehicle)) then 
					DeleteVehicle(vehicle) 
				end
        for impoundName, impound in pairs(Config.Impound) do
          if impound.IsDefaultImpound then
            TriggerServerEvent('kc_garage:impoundVehicle', impoundName)
          end
        end
			end
		end
	end
end)

function GetIcons(vehClass)
  if vehClass == 'Motorcycles' then
    return 'motorcycle'
  elseif vehClass == 'Cylces' then
    return 'bicycle'
  elseif vehClass == 'Boats' then
    return 'ship'
  elseif vehClass == 'Helicopters' then
    return 'helicopter'
  elseif vehClass == 'Planes'then
    return 'plane'
  else
    return 'car-side'
  end
end

function GetAvailableVehicleSpawnPoint(spawnPoints)
	local found, foundSpawnPoint = false, nil

	for i=1, #spawnPoints, 1 do
		if ESX.Game.IsSpawnPointClear(spawnPoints[i].Pos, 2.0) then
			found, foundSpawnPoint = true, spawnPoints[i]
			break
		end
	end

	if found then
		return true, foundSpawnPoint
	else
		TriggerEvent('kc_garage:notify', 'error', _K('veh_blocked'))
		return false
	end
end

function WaitForVehicleToLoad(modelHash)
	modelHash = (type(modelHash) == 'number' and modelHash or joaat(modelHash))

	if not HasModelLoaded(modelHash) then
		RequestModel(modelHash)

		BeginTextCommandBusyspinnerOn('STRING')
		AddTextComponentSubstringPlayerName(_K('load_assets'))
		EndTextCommandBusyspinnerOn(4)

		while not HasModelLoaded(modelHash) do
			Wait(0)
			DisableAllControlActions(0)
		end

		BusyspinnerOff()
	end
end

function GetGarageName(playerCoords, _type, value)
  if _type == 'key' then
    for Garage, v in pairs(Config[value]) do
      for i = 1, #v.DeletePoint do
        if #(playerCoords - v.DeletePoint[i].Pos) < 3.0 then
          return Garage
        end
      end
    end
  elseif _type == 'label' then
    for _, v in pairs(Config[value]) do
      if #(playerCoords - v.Coords) < 3.0 then
        return v.Label
      end
    end
  end
end

function HasPlayers(garage)
  local players = Config.Garages[garage].Players[1]
  if players then
    for i = 1, #players, 1 do
      local Player = players[i]
      if ESX.PlayerData.identifier == Player then
        return true
      end
    end
  else
    return true
  end
end

function HasGroups(garage)
  local Groups = Config.Garages[garage].Groups[1]
  if Groups then
    for i = 1, #Groups, 1 do
      local Group = Groups[i]
      if ESX.PlayerData.job.name == Group then
        return true
      end
    end
  else
    return true
  end
end

function SpawnNpc(coords, heading, model)
  local hash = GetHashKey(model)

  RequestModel(hash)
  while not HasModelLoaded(hash) do
    Wait(15)
  end

  local ped = CreatePed(4, hash, coords[1], coords[2], coords[3] - 1, 3374176, false, true)
  SetEntityHeading(ped, heading)
  FreezeEntityPosition(ped, true)
  SetEntityInvincible(ped, true)
  SetBlockingOfNonTemporaryEvents(ped, true)
end

function EnumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
		local iter, id = initFunc()
		if not id or id == 0 then
			disposeFunc(iter)
			return
		end

		local enum = {handle = iter, destructor = disposeFunc}
		setmetatable(enum, entityEnumerator)

		local next = true
		repeat
			coroutine.yield(id)
			next, id = moveFunc(iter)
		until not next

		enum.destructor, enum.handle = nil, nil
		disposeFunc(iter)
	end)
end

function EnumerateVehicles()
	return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

RegisterKeyMapping('lockvehicle', 'Toggle vehicle locks', 'keyboard', 'U')
RegisterCommand('lockvehicle', function()
  local vehicle, dist = ESX.Game.GetClosestVehicle()

  if dist < 10 and vehicle > 0 then
    local plate = ESX.Game.GetVehicleProperties(vehicle).plate
    ClearPedTasks(PlayerPedId())
    Wait(100)
    TriggerServerEvent('kc_garage:requestVehicleLock', VehToNet(vehicle), GetVehicleDoorLockStatus(vehicle), plate)
  end
end)

RegisterCommand('givekeys', function()
  local closestP, closestD = ESX.Game.GetClosestPlayer()
  local vehicle, dist = ESX.Game.GetClosestVehicle()
  if DoesEntityExist(vehicle) and closestP ~= -1 and closestD < 4 and dist < 10 then
    local plate = ESX.Game.GetVehicleProperties(vehicle).plate
    TriggerServerEvent('kc_garage:GiveKeyToPerson', plate, GetPlayerServerId(closestP))
  else
    TriggerEvent('kc_garage:notify', 'error', _K('not_found'))
  end
end)

RegisterCommand(Config.CmdVehDelete, function()
  ESX.TriggerServerCallback('kc_garage:getPlayersGroup', function(allowed)
    if allowed then
      TriggerEvent('kc_garage:deleteVehicle')
    else
      TriggerEvent('kc_garage:notify', 'error', _K('not_allowed'))
    end
  end)
end)

exports('JobsImpound', function(impoundLoc, plate, vehicleProps, identifier)
  TriggerServerEvent('kc_garage:jobsImpoundVehicle', impoundLoc, plate, vehicleProps, identifier)
  DeleteVehicle(vehicleProps.model)
end)