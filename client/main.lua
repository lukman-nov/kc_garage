local ESX = nil

CreateThread(function()
	while ESX == nil do
		ESX = exports["es_extended"]:getSharedObject()
		Wait(10)
	end 
end)

function addonNPC(x, y, z, heading)
  RequestModel(GetHashKey(Config.Ped.Model))
  while not HasModelLoaded(GetHashKey(Config.Ped.Model)) do
      Wait(15)
  end
  ped = CreatePed(4, Config.Ped.Hash, x, y, z - 1, 3374176, false, true)
  SetEntityHeading(ped, heading)
  FreezeEntityPosition(ped, true)
  SetEntityInvincible(ped, true)
  SetBlockingOfNonTemporaryEvents(ped, true)
end

CreateThread(function()
  for _, v in pairs(Config.Garages) do
    addonNPC(v.EntryPoint[1],v.EntryPoint[2],v.EntryPoint[3], v.PedHeading)
  end
end)

CreateThread(function()
  for _, v in pairs(Config.Garages) do
    if v.Blip then
      local blip = AddBlipForCoord(v.EntryPoint)
      SetBlipSprite(blip, 357)
      SetBlipColour(blip, 3)
      SetBlipDisplay(blip, 2)
      SetBlipScale(blip, 0.8)
      SetBlipAsShortRange(blip, true)
      BeginTextCommandSetBlipName('STRING')
      AddTextComponentSubstringPlayerName(_U('garage', v.Name))
      EndTextCommandSetBlipName(blip)
    end
  end
end)

CreateThread(function()
  exports.ox_target:addModel('CSB_TrafficWarden', {
    {
      name = 'getVehGarage',
      icon = 'fa-solid fa-car',
      label = _U('get_vehicle'),
      event = 'kc_garage:getVehList'
    },
  })
end)

CreateThread(function()
  while true do
    local Sleep = 2000
		local playerPed = GetPlayerPed(-1)
    local playerCoords = GetEntityCoords(playerPed)
		local vehicle = GetVehiclePedIsIn(playerPed, false)
    local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
    local isInVehicle = IsPedInAnyVehicle(playerPed, false)

    if isInVehicle then
      for k, v in pairs(Config.Garages) do
        if #(playerCoords - v.DeletePoint) < 10.0 then
          Sleep = 0
          DrawMarker(Config.MarkerType, v.DeletePoint, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.ZoneSize.x, Config.ZoneSize.y, Config.ZoneSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
          if IsControlJustReleased(0, 38) then
            ESX.TriggerServerCallback('kc_garage:checkVehicleOwner', function(owner)
              if owner then 
                TaskLeaveVehicle(playerPed, vehicle, 1)
                Wait(2000)
                DeleteVehicle(vehicle)
                TriggerServerEvent('kc_garage:updateOwnedVehicle', 1, k, false, vehicleProps)
              else
                TriggerEvent('kc_garage:notify', 'error', _U('not_yours_vehicle'))
              end
            end, vehicleProps.plate)
          end
        end
      end
    end
    Wait(Sleep)
  end
end)

RegisterNetEvent('kc_garage:getVehList')
AddEventHandler('kc_garage:getVehList', function()
	local playerPed = GetPlayerPed(-1)
  local playerCoords = GetEntityCoords(playerPed)
  ESX.TriggerServerCallback('kc_garage:getVehiclesInParking', function(vehicles)
    local vehiclesTableList = {}
    local garage

    for _, v in pairs(Config.Garages) do
      if #(playerCoords - v.EntryPoint) < 3.0 then
        garage = v.Name
      end
    end

    if vehicles then
      for i = 1, #vehicles, 1 do
        local engineHealth = vehicles[i].vehicle.engineHealth * 100 / 1000

        if #(playerCoords - Config.Garages[vehicles[i].parking].EntryPoint) < 3.0 then
          vehiclesTableList[GetDisplayNameFromVehicleModel(vehicles[i].vehicle.model)] = {
            description = 'Engine: '..engineHealth..'% | Fuel: '..vehicles[i].vehicle.fuelLevel.. '%',
            event = 'kc_garage:spawnVehicle',
            args = {
              model = vehicles[i].vehicle.model,
              parking = vehicles[i].parking,
              props = vehicles[i].vehicle,
              eHealth = vehicles[i].vehicle.engineHealth,
              bHealth = vehicles[i].vehicle.bodyHealth,
              tHealth = vehicles[i].vehicle.tankHealth
            },
            metadata = {
              ['Parking'] = Config.Garages[vehicles[i].parking].Name, 
              ['Plate'] = vehicles[i].plate
            }
          }
        end
      end
      lib.registerContext({
        id = 'garage_menu',
        title = _U('garage', garage),
        options = vehiclesTableList
      })
      lib.showContext('garage_menu')
    end
  end)
end)

RegisterNetEvent('kc_garage:spawnVehicle')
AddEventHandler('kc_garage:spawnVehicle', function(data)
  if ESX.Game.IsSpawnPointClear(Config.Garages[data.parking].SpawnPoint.pos, 2.5) then
    ESX.Game.SpawnVehicle(data.model, Config.Garages[data.parking].SpawnPoint.pos, Config.Garages[data.parking].SpawnPoint.heading, function(vehicle)
      ESX.Game.SetVehicleProperties(vehicle, data.props)
      SetEntityAsMissionEntity(vehicle, true, true)
      SetVehicleEngineHealth(vehicle, data.eHealth + 0.0)
      if Config.LegacyFuel then
        exports["LegacyFuel"]:SetFuel(vehicle, data.props.fuelLevel)
      else 
        SetVehicleFuelLevel(vehicle, data.props.fuelLevel)
      end
      TaskWarpPedIntoVehicle(GetPlayerPed(-1), vehicle, -1)
      SetVehicleEngineOn(vehicle, true, true)

      local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
      TriggerServerEvent('kc_garage:updateOwnedVehicle', 2, false, false, vehicleProps)
    end)
  else
    TriggerEvent('kc_garage:notify', 'error', _U('veh_block'))
  end
end)

RegisterNetEvent('kc_garage:CarLockedEffect')
AddEventHandler('kc_garage:CarLockedEffect', function(netId, lockStatus)
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
      TriggerEvent('kc_garage:notify', 'inform', _U('vehicle_locked'))
    else
      TriggerEvent('kc_garage:notify', 'inform', _U('vehicle_unlocked'))
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

RegisterNetEvent('kc_garage:notify')
AddEventHandler('kc_garage:notify', function(type, args)
  if Config.Notify == 'mythic_notify' then
    exports['mythic_notify']:DoHudText(type, args)
  elseif Config.Notify == 'lib' then
    lib.notify({
      description = args,
      type = type
    })
  elseif Config.Notify == 'ESX' then
    ESX.ShowNotification(args)
  end
end)

RegisterCommand('lockvehicle', function()
  local vehicle, dist = ESX.Game.GetClosestVehicle()

  if dist < 10 and vehicle > 0 then
    local plate = ESX.Game.GetVehicleProperties(vehicle).plate
    ClearPedTasks(PlayerPedId())
    Wait(100)
    TriggerServerEvent('kc_garage:RequestVehicleLock', VehToNet(vehicle), GetVehicleDoorLockStatus(vehicle), plate)
  else 
    TriggerEvent('kc_garage:notify', 'error', _U('no_vehicle'))
  end
end)

RegisterKeyMapping('lockvehicle', _U('lock_vehicle'), 'keyboard', 'U')

RegisterCommand('givekeys', function()
  local closestP, closestD = ESX.Game.GetClosestPlayer()
  local vehicle, dist = ESX.Game.GetClosestVehicle()
  if DoesEntityExist(vehicle) and closestP ~= -1 and closestD < 4 and dist < 10 then
    local plate = ESX.Game.GetVehicleProperties(vehicle).plate
    TriggerServerEvent('kc_garage:GiveKeyToPerson', plate, GetPlayerServerId(closestP))
  else
    TriggerEvent('kc_garage:notify', 'inform', _U('no_players'))
  end
end)