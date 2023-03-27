<div align="center">
<img src="https://media.discordapp.net/attachments/901446802711142460/1060136243377229874/KC.png" width="30%">
<h1><b>KUCLUCK GARAGE</b></h1>
<p>Kucluck Garages, this is a garage script that has many functions. Starting from the garage of cars, planes or helicopters, and boats, it can also be used to seize vehicles manually or automatically using a predetermined time, and there is also a vehicle lock system. This garage can also be made into private garages, jobs or groups of garages or public garages.

This script is only useful in the ESX Legacy framework, because when I made this script I used the <b>ESX Legacy 1.9.3</b> framework and <b>Game build 2802</b>.

Sorry if this script looks bad :D
Hopefully this script is useful for those of you who download it.

I share this script with you for free.

## <b>⚠️ !!! DO NOT TRADE THIS SCRIPT !!! ⚠️</b>

</p>
</div>

<div align="center">
<a href="https://youtu.be/sb_Y4lud-IM"><img src="https://media.discordapp.net/attachments/1060165701136044052/1088129652104634388/kc_garage.png"></a>
</div>

### 📺 [Preview](https://youtu.be/sb_Y4lud-IM)

### ✅ Main Features

- Low Resmon (_if you use ox_target_).
- Save Engine Level, Body Level, Fuel Level, Visual Dirt Body and etc.
- Include database, and NPC.
- Include vehicles key System.
- Include Impound and Jobs Impounded.
- Include Private Garage and Jobs Garage.
- Incluce cars, planes or helicopters, and boats Garage & Impound,
- Custom Fee Impound & Fee Garages from vehicle type.
- Include Auto and Manualy Delete Vehicles in Words.
- And more 😄

### ⚙️ Framework

- ESX

### ⚠️ Requirements

- <a href='https://github.com/overextended/ox_lib'>ox_lib</a>

### ➕ Optional Needs

- <a href='https://github.com/JayMontana36/mythic_notify'>mythic_notify</a>
- <a href='https://github.com/overextended/ox_target'>ox_target</a>

### 🧰 Usage

```lua
exports['kc_garage']:JobsImpound('ImpoundName', vehicle, ESX.PlayerData.identifier)

-- [[ EXAMPLE ]] --
RegisterCommand('JobsImpound', function()
  local vehicle = ESX.Game.GetClosestVehicle()
  exports['kc_garage']:JobsImpound('JobsImpound', vehicle, ESX.GetPlayerData().identifier)
end)
```

```lua
Config.Garages = {
  Legion = { -- key garages to input databases
    Label = 'Legion', -- garage label
    Type = 'car', -- 'car', 'aircraft' and 'boat'
    Blip = true, -- if private garages you can set false
    NotFree = true, -- fee garages
    Coords = vector3(214.6728, -806.7095, 30.8073), -- blips and ped coords
    PedHeading = 337.9022, -- ped heading
    Players = { -- Players table allowed to access garages
      -- ex: {'steam:xxxxxxxxxxxx'}
    },
    Groups = { -- Groups table allowed to access garages
      -- ex: {'police'}
    },
    SpawnPoint = {
      { Pos = vector3(221.3627, -809.6945, 30.1290), Heading = 248.5339 },
      { Pos = vector3(221.9424, -807.0797, 30.1476), Heading = 248.5339 },
      { Pos = vector3(222.7534, -804.3437, 30.1486), Heading = 248.5339 },
      { Pos = vector3(223.8556, -801.9759, 30.1351), Heading = 248.5339 },
      { Pos = vector3(224.4868, -799.4138, 30.1383), Heading = 248.5339 },
      { Pos = vector3(225.3986, -796.8544, 30.1434), Heading = 248.5339 },
    },
    DeletePoint = {
      { Pos = vector3(206.0533, -800.8460, 30.9834) },
      { Pos = vector3(206.8243, -798.4073, 30.9834) },
      { Pos = vector3(207.7707, -796.0760, 30.9834) },
      { Pos = vector3(209.2426, -793.8544, 30.9834) },
      { Pos = vector3(210.0643, -791.2812, 30.9834) },
    }
  },
}
```

## 🛠️ <b> How To Fix NULL Vehicle Label</b>

<div align="center"><img src="https://media.discordapp.net/attachments/1060165701136044052/1087603093962772541/image.png"/></div>

To fix NULL vehicle names when selecting a vehicle you need to add code in vehicle_names.lua for ex: `AddTextEntry('23rs7', 'AUDI RS7 2023')` the first is `<gameName>` and the second is the vehicle's custom Label. to get `<gameName>` you need to look at the vehicle data in `vehicles.meta`.

<div align="center"><img src="https://media.discordapp.net/attachments/1060165701136044052/1087603452181487716/image.png"/></div>

```lua
CreateThread(function()
  AddTextEntry('23rs7', "AUDI RS7 2023") -- (<gameName>, Vehicle Label)
end)
```

<hr>

<div align="center"> <a href="https://discord.gg/BuACxn4XUw" title=""><img alt="Discord Invite" src="https://discordapp.com/api/guilds/901445288881963059/widget.png?style=banner2"></a>
</div>

<p align="center">©️ <a href="https://discord.gg/BuACxn4XUw">Kucluck Official</a> 2023 - All rights reserved.</p>
