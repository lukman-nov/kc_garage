local ESX = nil
local MDI = 50
local DDT = 0.05
local inAnim = false
local isDead = false

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

-- Thread
CreateThread(function() -- Framework
	while ESX == nil do
		ESX = exports["es_extended"]:getSharedObject()
		Wait(10)
	end 
  
	while ESX.GetPlayerData().job == nil and ESX.GetPlayerData() == nil do
		Citizen.Wait(10)
	end
	ESX.PlayerData = ESX.GetPlayerData()
end)

CreateThread(function() -- Create Blips And Spawn Peds
  for _, v in pairs(Config.Garages) do
    if v.Blip then
      local blip = AddBlipForCoord(v.Coords)
      for blipsType, blips in pairs(Config.Blips.Garages) do
        if blipsType == v.Type then
          SetBlipSprite(blip, blips.Sprite)
          SetBlipColour(blip, blips.Colour)
          SetBlipDisplay(blip, blips.Display)
          SetBlipScale(blip, blips.Scale)
        end
      end
      SetBlipAsShortRange(blip, true)
      BeginTextCommandSetBlipName('STRING')
      AddTextComponentSubstringPlayerName(_K('garage', v.Label))
      EndTextCommandSetBlipName(blip)
    end
    SpawnNpc(v.Coords, v.PedHeading, Config.Peds[1])
  end

  for _, v in pairs(Config.Impound) do
    if v.Blip then
      local blip = AddBlipForCoord(v.Coords)
      for blipsType, blips in pairs(Config.Blips.Impounds) do
        if blipsType == v.Type then
          SetBlipSprite(blip, blips.Sprite)
          SetBlipColour(blip, blips.Colour)
          SetBlipDisplay(blip, blips.Display)
          SetBlipScale(blip, blips.Scale)
        end
      end
      SetBlipAsShortRange(blip, true)
      BeginTextCommandSetBlipName('STRING')
      AddTextComponentSubstringPlayerName(_K('impound', v.Label))
      EndTextCommandSetBlipName(blip)
    end
    SpawnNpc(v.Coords, v.PedHeading, Config.Peds[2])
  end
end)

CreateThread(function() -- ox_target Get and Save Vehicle
  if Config.UseTarget then
    exports.ox_target:addModel(Config.Peds, {
      {
        name = 'getVehGarage',
        icon = 'fa-solid fa-car',
        label = _K('get_veh_list'),
        onSelect = function(data)
          for garageName, garage in pairs(Config.Garages) do
            if #(data.coords - garage.Coords) < 2.0 then
              data.vehType = garage.Type
              data.stored = 1
              data.parkingKey = garageName
              data.NotFree = garage.NotFree
              data.spawnPoints = garage.SpawnPoint
              PlayAnim(Config.UseAnim)
              GetVehInGarage(data)
            end
          end
        end,
        canInteract = function(entity, distance, coords, name, bone)
          for garageName, garage in pairs(Config.Garages) do
            if #(coords - garage.Coords) < 2.0 then 
              if distance < 2.0 and HasPlayers(garageName) and HasGroups(garageName) and not isDead then return true end
            end
          end
        end
      },
      {
        name = 'getVehImpound',
        icon = 'fa-solid fa-car',
        label = _K('get_veh_list'),
        onSelect = function(data)
          for impoundName, impound in pairs(Config.Impound) do
            if #(data.coords - impound.Coords) < 2.0 then
              data.vehType = impound.Type
              data.stored = 0
              data.parkingKey = impoundName
              data.NotFree = impound.NotFree
              data.spawnPoints = impound.SpawnPoint
              PlayAnim(Config.UseAnim)
              GetVehInImpound(data)
            end
          end
        end,
        canInteract = function(entity, distance, coords, name, bone)
          for garageName, impound in pairs(Config.Impound) do
            if distance < 2.0 and #(coords - impound.Coords) < 2.0 and not isDead then return true end
          end
        end
      },
    })
    
    for garageName, garage in pairs(Config.Garages) do
      for i = 1, #garage.DeletePoint do
        exports.ox_target:addGlobalVehicle({
          {
            name = 'storedVeh',
            icon = 'fa-solid fa-square-parking',
            label = _K('parking'),
            onSelect = function(data)
              if #(data.coords - garage.DeletePoint[i].Pos) < 2.0 then
                SaveVeh(garageName, data.entity)
              end
            end,
            canInteract = function(entity, distance, coords, name, bone)
              if #(coords - garage.DeletePoint[i].Pos) < 2.0 and HasPlayers(garageName) and HasGroups(garageName) and not isDead then return true end
            end
          }
        })
      end
    end
  end
end)

CreateThread(function() -- not ox_target Get and Save Vehicle
  while not Config.UseTarget do 
    local Sleep = 1500
    local playerCoords = GetEntityCoords(GetPlayerPed(-1))
    local tempData = {}

    for garageName, garage in pairs(Config.Garages) do
      if #(playerCoords - garage.Coords) < 3.0  and not isDead then
        if HasPlayers(garageName) and HasGroups(garageName) and not IsPedInAnyVehicle(GetPlayerPed(-1), false) then
          Sleep = 0
          tempData.type = 'Garages'
          tempData.vehType = garage.Type
          tempData.stored = 1
          tempData.parkingKey = garageName
          tempData.spawnPoints = garage.SpawnPoint
          tempData.NotFree = garage.NotFree
          ESX.Game.Utils.DrawText3D(vector3(garage.Coords.x, garage.Coords.y, garage.Coords.z + 1.0), _K('press_get_veh'), 1.0, 4)
          if IsControlJustReleased(0, 38) then
            PlayAnim(Config.UseAnim)
            GetVehInGarage(tempData)
            tempData = {}
          end
        end
      end
      
      for i = 1, #garage.DeletePoint, 1 do
        if #(playerCoords - garage.DeletePoint[i].Pos) < 10  and not isDead then
          if IsPedInAnyVehicle(GetPlayerPed(-1), false) and HasPlayers(garageName) and HasGroups(garageName) then
            DrawMarker(36, garage.DeletePoint[i].Pos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 100, 100, 100, false, true, 2, true, false, false, false)   
            Sleep = 0
            local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
            if #(playerCoords - garage.DeletePoint[i].Pos) < 2.0 then
              if IsControlJustReleased(0, 38) then
                SaveVeh(garageName, vehicle)
              end
            end
          end
        end
      end
    end

    for impoundName, impound in pairs(Config.Impound) do
      if not IsPedInAnyVehicle(GetPlayerPed(-1), false) and not isDead then
        if #(playerCoords - impound.Coords) < 3.0 then
          Sleep = 0
          tempData.type = 'Impound'
          tempData.vehType = impound.Type
          tempData.stored = 0
          tempData.parkingKey = impoundName
          tempData.spawnPoints = impound.SpawnPoint
          tempData.notFree = impound.NotFree
          ESX.Game.Utils.DrawText3D(vector3(impound.Coords.x, impound.Coords.y, impound.Coords.z + 1.0), _K('press_get_veh'), 1.0, 4)
          if IsControlJustReleased(0, 38) then
            PlayAnim(Config.UseAnim)
            GetVehInImpound(tempData)
            tempData = {}
          end
        end
      end
    end
    Wait(Sleep)
  end
end)

CreateThread(function() -- Auto Save Vehicle Properties
  while true do
    Sleep = 2500
    if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
      Sleep = 1000
      local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
      local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
      vehicleProps.deformation = GetVehicleDeformation(vehicle)
      TriggerServerEvent('kc_garage:updateVehicleProperties', vehicleProps.plate, vehicleProps)
    end
    Wait(Sleep)
  end
end)

-- Event
RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(job)
  ESX.PlayerData.job = job
end)

AddEventHandler('esx:onPlayerDeath', function(data) 
  isDead = true
end)

AddEventHandler('esx:onPlayerSpawn', function(data)
	isDead = false
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  Wait(500)
  ESX.PlayerData = xPlayer
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
    if _type == 'inform' then _type = 'info' end
    ESX.ShowNotification(args, _type)
  end
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

RegisterNetEvent('kc_garage:deleteAllVehicles')
AddEventHandler('kc_garage:deleteAllVehicles', function()
  local minuteCalculation = 6000
  local minutesPassed = 0
  local minutesLeft = Config.DeleteVehicleTimer

  TriggerEvent('kc_garage:notify', 'inform', _K('del_veh_msg', minutesLeft))

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
        TriggerServerEvent('kc_garage:filterVehiclesType')
        -- TriggerServerEvent('kc_fuel:UpdateVehicleDateTimeIn', plate) -- REMOVE THIS
			end
		end
	end
end)

RegisterNetEvent('kc_garage:setCoords')
AddEventHandler('kc_garage:setCoords', function(coords)
  SetNewWaypoint(coords.x, coords.y)
  TriggerEvent('kc_garage:notify', 'success', _K('gps_set'))
end)

RegisterNetEvent('kc_garage:spawnVehicle')
AddEventHandler('kc_garage:spawnVehicle', function(data)
  local foundSpawn, SpawnPoint = GetAvailableVehicleSpawnPoint(data.spawnPoints)
  if foundSpawn then
    WaitForVehicleToLoad(data.vehicle.model)
    ESX.Game.SpawnVehicle(data.vehicle.model, SpawnPoint.Pos, SpawnPoint.Heading, function(vehicle)
      SetVehicleEngineHealth(vehicle, data.vehicle.engineHealth)
      SetVehicleFuelLevel(vehicle, data.vehicle.fuelLevel)
      SetVehicleBodyHealth(vehicle, data.vehicle.bodyHealth)
      SetVehicleDeformation(vehicle, data.vehicle.deformation or GetVehicleDeformation(vehicle))
      ESX.Game.SetVehicleProperties(vehicle, data.vehicle)
      
      if Config.AutoTeleportToVehicle then
        TaskWarpPedIntoVehicle(GetPlayerPed(-1), vehicle, -1)
        SetVehicleEngineOn(vehicle, true, true)
      end
  
      if Config.AutoLockVeh then
        SetVehicleDoorsLocked(vehicle, 2)
      end
  
      for impoundName, impound in pairs(Config.Impound) do
        if data.vehType == impound.Type then
          if impound.IsDefaultImpound then
            TriggerServerEvent('kc_garage:updateStoredVehicle', 0, impoundName, data.vehicle.plate)
          end
        end
      end
      TriggerEvent('kc_garage:notify', 'success', _K('veh_spawn'))
    end)
  end
end)

-- Function
function GetVehInGarage(data)
  ESX.TriggerServerCallback('kc_garage:getVehiclesInParking', function(vehData)
    local vehicleList = {}
    for i = 1, #vehData, 1 do
      if Config.ShowVehImpoundInGarage then
        vehicleList['! Show vehicles in impound'] = {
          icon = 'lock',
          arrow = true,
          onSelect = function() GetVehInImpound(data, 'Garages') end,
        }
      end
      
      local price = Config.VehicleFee.Garages[GetVehicleClassFromName(vehData[i].vehicle.model)]
      local color = '#2B8A3E'

      if vehData[i].parking ~= data.parkingKey then
        price = math.floor(price * Config.FeeSpawnVehicleInAnyGarage[1])
        color = '#C92A2A'
      end
      
      if data.vehType == vehData[i].vehType and vehData[i].stored then
        local vehLabel = GetLabelText(GetDisplayNameFromVehicleModel(vehData[i].vehicle.model))
        vehicleList[vehLabel..' | '..vehData[i].plate] = {
          description = _K('engine')..toPercent(vehData[i].vehicle.engineHealth)..'% | '.._K('body')..toPercent(vehData[i].vehicle.bodyHealth)..'% | '.._K('fuel')..vehData[i].vehicle.fuelLevel.. '%',
          icon = GetIcons(vehicleClassName[GetVehicleClassFromName(vehData[i].vehicle.model)]),
          iconColor = color or nil,
          metadata = {
            [_K('parking')] = GetParkingLabel(vehData[i].parking, 'Garages', vehData[i].vehType), 
            [_K('plate')] = vehData[i].plate,
            [_K('fee')] = price,
            [_K('type')] = vehicleClassName[GetVehicleClassFromName(vehData[i].vehicle.model)]
          },
          onSelect = function()
            spawnData = {
              type = 'Garages',
              vehType = vehData[i].vehType,
              spawnPoints = data.spawnPoints,
              vehicle = vehData[i].vehicle,
              price = price,
              notFree = data.NotFree
            }
            PlayAnim(Config.UseAnim)
            if Config.SpawnVehicleInAnyGarage then
              TriggerServerEvent('kc_garage:vehicleChecking', spawnData)
            else
              if vehData[i].parking == data.parkingKey then
                TriggerServerEvent('kc_garage:vehicleChecking', spawnData)
              else
                TriggerEvent('kc_garage:notify', 'error', _K('canot_spawn_here'))
              end
            end
          end,
        }
      end
    end
    lib.registerContext({
      id = 'kc_garage:openVehicleGaragesMenu',
      title = GetParkingLabel(data.parkingKey, 'Garages', data.vehType),
      options = vehicleList,
      onExit = function()
        PlayAnim(Config.UseAnim)
      end
    })
    lib.showContext('kc_garage:openVehicleGaragesMenu')
  end)
end

function GetVehInImpound(data, key)
  ESX.TriggerServerCallback('kc_garage:getVehiclesInParking', function(vehData)
    local vehicleList = {}
    for i = 1, #vehData, 1 do
      if data.vehType == vehData[i].vehType and not vehData[i].stored then

        local vehLabel = GetLabelText(GetDisplayNameFromVehicleModel(vehData[i].vehicle.model))
        local price = Config.VehicleFee.Impound[GetVehicleClassFromName(vehData[i].vehicle.model)]
        local color = '#2B8A3E'

        if vehData[i].parking ~= data.parkingKey then
          price = math.floor(price * Config.FeeSpawnVehicleInAnyGarage[2])
          color = '#C92A2A'
        end
        
        vehicleList[vehLabel..' | '..vehData[i].plate] = {
          description = _K('engine')..toPercent(vehData[i].vehicle.engineHealth)..'% | '.._K('body')..toPercent(vehData[i].vehicle.bodyHealth)..'% | '.._K('fuel')..vehData[i].vehicle.fuelLevel.. '%',
          icon = GetIcons(vehicleClassName[GetVehicleClassFromName(vehData[i].vehicle.model)]),
          iconColor = color or nil,
          metadata = {
            [_K('parking')] = GetParkingLabel(vehData[i].parking, 'Impound', vehData[i].vehType), 
            [_K('plate')] = vehData[i].plate,
            [_K('fee')] = price,
            [_K('type')] = vehicleClassName[GetVehicleClassFromName(vehData[i].vehicle.model)]
          },
          onSelect = function()
            spawnData = {
              type = 'Impound',
              vehType = vehData[i].vehType,
              spawnPoints = data.spawnPoints,
              vehicle = vehData[i].vehicle,
              price = price,
              notFree = data.NotFree
            }
            PlayAnim(Config.UseAnim)
            if Config.SpawnVehicleInAnyGarage and not string.match(vehData[i].parking, 'Jobs') then
              TriggerServerEvent('kc_garage:vehicleChecking', spawnData)
            else
              if vehData[i].parking == data.parkingKey then
                TriggerServerEvent('kc_garage:vehicleChecking', spawnData)
              else
                TriggerEvent('kc_garage:notify', 'error', _K('canot_spawn_here'))
              end
            end
          end,
        }
      end
    end
    
    local menu = 'kc_garage:openVehicleGaragesMenu'

    if key == nil then 
      key = 'Impound'
      menu = nil
    end

    lib.registerContext({
      id = 'kc_garage:openVehicleListImpoundMenu',
      title = GetParkingLabel(data.parkingKey, key, data.vehType),
      options = vehicleList,
      menu = menu,
      onExit = function()
        PlayAnim(Config.UseAnim)
      end
    })
    lib.showContext('kc_garage:openVehicleListImpoundMenu')
  end)
end

function SaveVeh(garageName, vehicle)
  local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
  vehicleProps.deformation = GetVehicleDeformation(vehicle)
  ESX.TriggerServerCallback('kc_garage:checkVehicleOwner', function(vehType)
    if Config.Garages[garageName].Type == vehType then
      if not Config.UseTarget then
        TaskLeaveVehicle(GetPlayerPed(-1), vehicle, 1)
        Wait(2000)
      end
      
      if DoesEntityExist(vehicle) then
        DeleteVehicle(vehicle)
        TriggerServerEvent('kc_garage:updateOwnedVehicle', 1, garageName, vehicleProps)
      end
    else
      TriggerEvent('kc_garage:notify', 'error', _K('canot_store'))
    end
  end, vehicleProps.plate)
end

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
		AddTextComponentSubstringPlayerName('DOWNLOADING ASSETS...')
		EndTextCommandBusyspinnerOn(4)

		while not HasModelLoaded(modelHash) do
			Wait(0)
			DisableAllControlActions(0)
		end

		BusyspinnerOff()
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

function GetVehicleDeformation(vehicle)
	local offsets = GetVehicleOffsetsForDeformation(vehicle)
	local deformationPoints = {}
	for i, offset in ipairs(offsets) do
		local dmg = math.floor(#(GetVehicleDeformationAtPos(vehicle, offset)) * 1000.0) / 1000.0
		if (dmg > DDT) then
			table.insert(deformationPoints, { offset, dmg })
		end
	end
	return deformationPoints
end

function SetVehicleDeformation(vehicle, deformationPoints, callback)
	if (not IsDeformationWorse(deformationPoints, GetVehicleDeformation(vehicle))) then return end

	Citizen.CreateThread(function()
		local fDeformationDamageMult = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fDeformationDamageMult")
		local damageMult = 20.0
		if (fDeformationDamageMult <= 0.55) then
			damageMult = 1000.0
		elseif (fDeformationDamageMult <= 0.65) then
			damageMult = 400.0
		elseif (fDeformationDamageMult <= 0.75) then
			damageMult = 200.0
		end

		local printMsg = false

		for i, def in ipairs(deformationPoints) do
			def[1] = vector3(def[1].x, def[1].y, def[1].z)
		end

		local deform = true
		local iteration = 0
		while (deform and iteration < MDI) do
			if (not DoesEntityExist(vehicle)) then return end

			deform = false

			for i, def in ipairs(deformationPoints) do
				if (#(GetVehicleDeformationAtPos(vehicle, def[1])) < def[2]) then
					SetVehicleDamage(
						vehicle, 
						def[1] * 2.0, 
						def[2] * damageMult, 
						1000.0, 
						true
					)

					deform = true
				end
			end

			iteration = iteration + 1

			Citizen.Wait(100)
		end
		if (callback) then
			callback()
		end
	end)
end

function IsDeformationWorse(newDef, oldDef)
  if newDef[1] == nil and oldDef[1] == nil then return false end
	if (oldDef == nil or #newDef > #oldDef) then
		return true
	elseif (#newDef < #oldDef) then
		return false
	end

	for i, new in ipairs(newDef) do
		local found = false
		for j, old in ipairs(oldDef) do
			if (new[1] == old[1]) then
				found = true

				if (new[2] > old[2]) then
					return true
				end
			end
		end

		if (not found) then
			return true
		end
	end

	return false
end

function GetVehicleOffsetsForDeformation(vehicle)
	local min, max = GetModelDimensions(GetEntityModel(vehicle))
	local X = Round((max.x - min.x) * 0.5, 2)
	local Y = Round((max.y - min.y) * 0.5, 2)
	local Z = Round((max.z - min.z) * 0.5, 2)
	local halfY = Round(Y * 0.5, 2)

	return {
		vector3(-X, Y,  0.0),
		vector3(-X, Y,  Z),

		vector3(0.0, Y,  0.0),
		vector3(0.0, Y,  Z),

		vector3(X, Y,  0.0),
		vector3(X, Y,  Z),


		vector3(-X, halfY,  0.0),
		vector3(-X, halfY,  Z),

		vector3(0.0, halfY,  0.0),
		vector3(0.0, halfY,  Z),

		vector3(X, halfY,  0.0),
		vector3(X, halfY,  Z),


		vector3(-X, 0.0,  0.0),
		vector3(-X, 0.0,  Z),

		vector3(0.0, 0.0,  0.0),
		vector3(0.0, 0.0,  Z),

		vector3(X, 0.0,  0.0),
		vector3(X, 0.0,  Z),


		vector3(-X, -halfY,  0.0),
		vector3(-X, -halfY,  Z),

		vector3(0.0, -halfY,  0.0),
		vector3(0.0, -halfY,  Z),

		vector3(X, -halfY,  0.0),
		vector3(X, -halfY,  Z),


		vector3(-X, -Y,  0.0),
		vector3(-X, -Y,  Z),

		vector3(0.0, -Y,  0.0),
		vector3(0.0, -Y,  Z),

		vector3(X, -Y,  0.0),
		vector3(X, -Y,  Z),
	}
end

function Round(value, numDecimals)
	return math.floor(value * 10^numDecimals) / 10^numDecimals
end

function toPercent(v)
  return math.floor(v * 100) / 1000
end

function JobsImpound(impoundLoc, vehicle, identifier)
  local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
  vehicleProps.deformation = GetVehicleDeformation(vehicle)

  TriggerServerEvent('kc_garage:jobsImpoundVehicle', impoundLoc, vehicleProps.plate, vehicleProps, identifier)

  if DoesEntityExist(vehicle) then
    DeleteVehicle(vehicle)
  end
end

function GetParkingLabel(configKey, configType, vehType)
  for k, v in pairs(Config[configType]) do
    if string.match(configKey, k) and vehType == v.Type then
      return v.Label
    end
  end
end

function PlayAnim(useAnim)
  if useAnim then
    SetPedCurrentWeaponVisible(GetPlayerPed(-1), 0, 1, 1, 1)
    local dict = 'amb@code_human_in_bus_passenger_idles@female@tablet@idle_a'
    local prop = 'prop_cs_tablet'
    
    while not HasModelLoaded(prop) do
        RequestModel(prop)
        Wait(10)
    end
    
    if not inAnim then
      inAnim = true

      while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(10)
      end
      
      TaskPlayAnim(GetPlayerPed(-1), dict, 'idle_a', 8.0, 8.0, -1, 49, 0.0, 0, 0, 0)
      local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
      local entityProp = CreateObject(GetHashKey(prop), x, y, z + 0.2,  true,  true, true)
      AttachEntityToEntity(entityProp, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 28422), -0.05, 0.00, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

    else
      inAnim = false
      local entityProp = GetClosestObjectOfType(GetEntityCoords(GetPlayerPed(-1)), 1.0, GetHashKey(prop), false, 0, 0)
      DeleteEntity(entityProp)
      ClearPedTasks(GetPlayerPed(-1))
      SetPedCurrentWeaponVisible(GetPlayerPed(-1), 1, 1, 1, 1)
    end
  end
end

-- Commands
RegisterKeyMapping('lockvehicle', 'Toggle vehicle locks', 'keyboard', Config.LockKeyVehicle)
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
    TriggerServerEvent('kc_garage:giveKeyToPerson', plate, GetPlayerServerId(closestP))
  else
    TriggerEvent('kc_garage:notify', 'error', _K('not_found'))
  end
end)

RegisterCommand(Config.CmdVehDelete, function()
  ESX.TriggerServerCallback('kc_garage:getPlayersGroup', function(allowed)
    if allowed then
      TriggerEvent('kc_garage:deleteAllVehicles')
    else
      TriggerEvent('kc_garage:notify', 'error', _K('not_allowed'))
    end
  end)
end)

-- Exports
exports('JobsImpound', JobsImpound)

-- RegisterCommand('JobsImpound', function()
--   local vehicle = ESX.Game.GetClosestVehicle()
--   JobsImpound('JobsImpound', vehicle, ESX.PlayerData.identifier)
-- end)