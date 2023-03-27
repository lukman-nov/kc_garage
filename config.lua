Config = {}
Config.CheckForUpdates = true  -- check for update available?
Config.Locale = 'en'  -- 'en' or 'id'
Config.UseTarget = true -- if you not use ox_target you can set false
Config.Notify = 'mythic_notify' -- 'mythic_notify', 'lib', 'ESX'
Config.UseAnim = true -- play animation when requesting vehicle list?
Config.ShowVehImpoundInGarage = true
Config.SpawnVehicleInAnyGarage = false -- if true, the fee will be multiplied.
Config.FeeSpawnVehicleInAnyGarage = {[1] = 2, [2] = 3} -- [1] = garages fee * 2, [2] = impound fee * 3 and if you set 0 it's the same as free

Config.AutoTeleportToVehicle = false -- auto teleport to vehicle if vehicle spawning
Config.AutoLockVeh = true -- auto lock to vehicle if vehicle spawning
Config.PayIn = 'money' -- Player can pay vehicle fee with 'money' or 'bank'
Config.LockKeyVehicle = 'U' -- https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/

Config.CmdVehDelete = 'asuransi' -- Admin command for delete vehicle in the words
Config.AutoDelVeh = true -- Automatically confiscate vehicles at a certain time, you can set the time in Config.DeleteVehiclesAt line 84 config.lua
Config.DeleteVehicleTimer = 180 -- in second
Config.DeleteVehiclesIfInSafeZone = true -- you can set safe zone in `Config.SafeZone` line 95 config.lua

Config.VehicleFee = { -- if set to 0 the player does not pay
  Garages = { -- Garage Fee
    [0] = 5000, -- Compacts
    [1] = 5000, -- Sedans
    [2] = 5000, -- SUVs
    [3] = 5000, -- Coupes
    [4] = 5000, -- Muscle
    [5] = 5000, -- Sports Classics
    [6] = 5000, -- Sports
    [7] = 5000, -- Super
    [8] = 2000, -- Motorcycles
    [9] = 5000, -- Off-road
    [10] = 5000, -- Industrial
    [11] = 5000, -- Utility
    [12] = 5000, -- Vans
    [13] = 0, -- Cylces
    [14] = 50000, -- Boats
    [15] = 50000, -- Helicopters
    [16] = 50000, -- Planes
    [17] = 5000, -- Service
    [18] = 0, -- Emergency
    [19] = 5000, -- Military
    [20] = 5000, -- Commercial
    [21] = 5000 -- Train 
  },
  Impound = { -- Impound Fee
    [0] = 15000, -- Compacts
    [1] = 15000, -- Sedans
    [2] = 15000, -- SUVs
    [3] = 15000, -- Coupes
    [4] = 15000, -- Muscle
    [5] = 15000, -- Sports Classics
    [6] = 15000, -- Sports
    [7] = 15000, -- Super
    [8] = 10000, -- Motorcycles
    [9] = 15000, -- Off-road
    [10] = 15000, -- Industrial
    [11] = 15000, -- Utility
    [12] = 15000, -- Vans
    [13] = 0, -- Cylces
    [14] = 150000, -- Boats
    [15] = 150000, -- Helicopters
    [16] = 150000, -- Planes
    [17] = 15000, -- Service
    [18] = 0, -- Emergency
    [19] = 15000, -- Military
    [20] = 15000, -- Commercial
    [21] = 15000 -- Train 
  }
}

Config.Peds = { -- Peds List
  'CSB_TrafficWarden', -- Garages
  's_m_y_construct_01' -- Impounds
}

Config.GroupAdminList= { -- Admin list to use Config.CmdVehDelete
  'dev',
  'moderator',
  'headadmin',
  'admin',
}

Config.DeleteVehiclesAt = { -- Automatic clock setting to delete or impound vehicles if there is no player inside.
	{['h'] = 00, ['m'] = 00},
	{['h'] = 03, ['m'] = 00},
	{['h'] = 06, ['m'] = 00},
	{['h'] = 09, ['m'] = 00},
	{['h'] = 12, ['m'] = 00},
	{['h'] = 15, ['m'] = 00},
	{['h'] = 18, ['m'] = 00},
	{['h'] = 21, ['m'] = 00},
}

Config.SafeZones = { -- If the vehicle is within the safe zone, it will not be deleted.
	{ ['x'] = -44.155646565, ['y'] = -1100.155646565, ['z'] = 26.267009735108, ['radius'] = 50.0},
	{ ['x'] = -1688.43811035156, ['y'] = -1073.62536621094, ['z'] = 13.1521873474121, ['radius'] = 200.0},
	{ ['x'] = -2195.1352539063, ['y'] = 4288.7290039063, ['z'] = 49.173923492432, ['radius'] = 150.0},
}

Config.Garages = { -- Garages Config
  Legion = { -- key garages to input databases
    Label = 'Legion', -- garage label
    Type = 'car', -- 'car', 'aircraft' and 'boat'
    Blip = true, -- if private garages you can set false
    NotFree = true, -- fee garages
    Coords = vector3(214.7889, -806.4965, 30.8092), -- blips and ped coords
    PedHeading = 341.4469, -- ped heading
    Players = { -- Players table allowed to access garages
      -- ex: {'steam:xxxxxxxxxxxx'}
    },
    Groups = { -- Groups table allowed to access garages
      -- ex: {'police'}
    },
    SpawnPoint = {
      { Pos = vector3(222.7534, -804.3437, 30.1486), Heading = 248.5339 },
      { Pos = vector3(223.8556, -801.9759, 30.1351), Heading = 248.5339 },
      { Pos = vector3(224.4868, -799.4138, 30.1383), Heading = 248.5339 },
      { Pos = vector3(225.3986, -796.8544, 30.1434), Heading = 248.5339 },
      { Pos = vector3(225.7808, -794.0939, 30.1681), Heading = 249.2099 },
      { Pos = vector3(226.4725, -791.5930, 30.1775), Heading = 248.3668 },
      { Pos = vector3(227.9673, -789.1436, 30.1805), Heading = 248.0247 },
    },
    DeletePoint = {
      { Pos = vector3(207.7707, -796.0760, 30.9834) },
      { Pos = vector3(209.2426, -793.8544, 30.9834) },
      { Pos = vector3(210.0643, -791.2812, 30.9834) },
      { Pos = vector3(210.9966, -788.7125, 30.4128) },
      { Pos = vector3(211.4733, -785.8821, 30.4111) },
      { Pos = vector3(212.6457, -783.4863, 30.3930) },
    }
  },

  Terminal = {
    Label = 'Terminal',
    Type = 'car',
    Blip = true,
    NotFree = true,
    Coords = vector3(1222.0289, -2961.0095, 5.8661), 
    PedHeading = 95.1120,
    Players = {
      
    },
    Groups = {
      
    },
    SpawnPoint = {
      { Pos = vector3(1217.5316, -2967.9685, 5.8661), Heading = 96.3912 },
    },
    DeletePoint = {
      { Pos = vector3(1217.5316, -2967.9685, 5.8661) }
    }
  },

  Festival = {
    Label = 'Festival',
    Type = 'car',
    Blip = true,
    NotFree = true,
    Coords = vector3(-1592.9933, -923.3627, 9.0223), 
    PedHeading = 53.7181,
    Players = {
      
    },
    Groups = {
      
    },
    SpawnPoint = {
      { Pos = vector3(-1598.6584, -923.6129, 8.4312), Heading = 139.0172 },
      { Pos = vector3(-1600.6407, -921.2331, 8.4414), Heading = 139.2408 },
      { Pos = vector3(-1603.2598, -919.4777, 8.4354), Heading = 140.2991 },
      { Pos = vector3(-1605.3907, -917.2253, 8.4415), Heading = 139.6384 },
      { Pos = vector3(-1607.4508, -914.8009, 8.4508), Heading = 140.9010 },
    },
    DeletePoint = {
      { Pos = vector3(-1594.1393, -918.3148, 8.4508) },
      { Pos = vector3(-1596.5669, -916.2999, 8.4508) },
      { Pos = vector3(-1598.9159, -914.2520, 8.4508) },
      { Pos = vector3(-1601.1835, -912.2111, 8.4508) },
      { Pos = vector3(-1603.5889, -910.2061, 8.4508) },
    }
  },

  Paleto = {
    Label = 'Paleto',
    Type = 'car',
    Blip = true,
    NotFree = true,
    Coords = vector3(79.6358, 6404.2163, 31.4458), 
    PedHeading = 131.1130,
    Players = {
      
    },
    Groups = {
      
    },
    SpawnPoint = {
      { Pos = vector3(61.8341, 6404.0713, 30.7141), Heading = 215.2714 },
      { Pos = vector3(59.0627, 6400.9746, 30.7144), Heading = 214.8043 },
      { Pos = vector3(64.7686, 6406.2705, 30.7141), Heading = 211.2245 }
    },
    DeletePoint = {
      { Pos = vector3(72.4021, 6404.3438, 30.7144) },
      { Pos = vector3(75.4666, 6401.4907, 30.7144) },
      { Pos = vector3(78.1349, 6398.5815, 30.7144) },
      { Pos = vector3(81.0012, 6395.9927, 30.7144) }
    }
  },

  SandyShoresG = {
    Label = 'Sandy Shores Garage',
    Type = 'car',
    Blip = true,
    NotFree = true,
    Coords = vector3(1894.9961, 3714.3591, 32.7538), 
    PedHeading = 118.3539,
    Players = {
      
    },
    Groups = {
      
    },
    SpawnPoint = {
      { Pos = vector3(1888.0814, 3716.1348, 32.3407), Heading = 121.8960 },
      { Pos = vector3(1885.9080, 3719.4238, 32.3447), Heading = 119.4130 },
      { Pos = vector3(1884.1178, 3722.4272, 32.3363), Heading = 118.8460 }
    },
    DeletePoint = {
      { Pos = vector3(1888.0814, 3716.1348, 32.3447)},
      { Pos = vector3(1885.9080, 3719.4238, 32.3447)},
      { Pos = vector3(1884.1178, 3722.4272, 32.3447)}
    }
  },

  MilitaryBase = {
    Label = 'Military Base',
    Type = 'car',
    Blip = true,
    NotFree = true,
    Coords = vector3(-1839.8710, 3027.7827, 32.8105), 
    PedHeading = 67.3806,
    Players = {

    },
    Groups = {
      
    },
    SpawnPoint = {
      { Pos = vector3(-1836.0492, 3034.3628, 32.8105), Heading = 63.4989 },
    },
    DeletePoint = {
      { Pos = vector3(-1836.0492, 3034.3628, 32.8105) }
    }
  },
  
  MirrorPark = {
    Label = 'Mirror Park',
    Type = 'car',
    Blip = true,
    NotFree = true,
    Coords = vector3(1035.1742, -765.1974, 57.9947), 
    PedHeading = 153.8849,
    Players = {
      
    },
    Groups = {
      
    },
    SpawnPoint = {
      { Pos = vector3(1027.6094, -771.8443, 57.5259), Heading = 145.7455 },
      { Pos = vector3(1030.7230, -773.7680, 57.5479), Heading = 143.9065 },
    },
    DeletePoint = {
      { Pos = vector3(1027.6094, -771.8443, 57.5479)},
      { Pos = vector3(1030.7230, -773.7680, 57.5479)},
    }
  },
  
  MekanikKota = {
    Label = 'Mekanik Kota',
    Type = 'car',
    Blip = false,
    NotFree = false,
    Coords = vector3(-384.0035, -140.4050, 38.6857), 
    PedHeading = 301.6765,
    Players = {
      
    },
    Groups = {
      {'mechanic'}
    },
    SpawnPoint = {
      { Pos = vector3(-381.7652, -137.0106, 38.1750), Heading = 298.8808 },
      { Pos = vector3(-379.4821, -139.7043, 38.1742), Heading = 299.6868 },
      { Pos = vector3(-378.4056, -143.2687, 38.1742), Heading = 299.8542 },
      { Pos = vector3(-376.9904, -146.4754, 38.1736), Heading = 298.1663 },
      { Pos = vector3(-383.5086, -134.0326, 38.1746), Heading = 298.9847 },
    },
    DeletePoint = {
      { Pos = vector3(-377.9358, -146.9984, 38.6855)},
      { Pos = vector3(-379.6500, -143.9189, 38.6858)},
      { Pos = vector3(-381.2789, -140.7843, 38.6862)},
      { Pos = vector3(-382.7863, -137.7034, 38.6863)},
      { Pos = vector3(-384.6477, -134.6727, 38.6863)},
    }
  },
  
  EclipseHospital = {
    Label = 'Eclipse Hospital',
    Type = 'car',
    Blip = true,
    NotFree = true,
    Coords = vector3(-656.2633, 351.4507, 78.1183), 
    PedHeading = 183.5614,
    Players = {
      
    },
    Groups = {
      
    },
    SpawnPoint = {
      { Pos = vector3(-658.0089, 348.9457, 77.6068), Heading = 175.7422 },
      { Pos = vector3(-658.0089, 348.9457, 77.6068), Heading = 175.7422 },
      { Pos = vector3(-661.4048, 349.1467, 77.6067), Heading = 175.7422 },
      { Pos = vector3(-664.7354, 349.3837, 77.6068), Heading = 175.7422 },
      { Pos = vector3(-668.1645, 349.8712, 77.6069), Heading = 175.7422 },
      { Pos = vector3(-671.7061, 350.3329, 77.6067), Heading = 175.7422 },
    },
    DeletePoint = {
      { Pos = vector3(-658.0089, 348.9457, 77.6067) },
      { Pos = vector3(-661.4048, 349.1467, 77.6067) },
      { Pos = vector3(-664.7354, 349.3837, 77.6067) },
      { Pos = vector3(-668.1645, 349.8712, 77.6067) },
      { Pos = vector3(-671.7061, 350.3329, 77.6067) },
    }
  },
  
  KucluckHouse = {
    Label = 'Kucluck House',
    Type = 'car',
    Blip = false,
    NotFree = false,
    Coords = vector3(-548.7320, 5004.7842, 153.5449), 
    PedHeading = 235.7023,
    Players = {
      
    },
    Groups = {
      
    },
    SpawnPoint = {
      { Pos = vector3(-541.0726, 5009.7109, 153.5407), Heading = 232.1175 },
    },
    DeletePoint = {
      { Pos = vector3(-541.0726, 5009.7109, 153.5407) },
    }
  },

  PoliceGarage = {
    Label = 'Police Garage',
    Type = 'car',
    Blip = false,
    NotFree = false,
    Coords = vector3(459.1317, -1010.4518, 28.1798),
    PedHeading = 82.2547,
    Players = {
      
    },
    Groups = {
      {'police'}
    },
    SpawnPoint = {
      { Pos = vector3(446.0918, -1024.0363, 28.5160), Heading = 4.0892 },
      { Pos = vector3(442.3278, -1025.4196, 28.6097), Heading = 6.3928 },
      { Pos = vector3(438.3373, -1025.7689, 28.6909), Heading = 7.4139 },
      { Pos = vector3(434.7534, -1026.3446, 28.7670), Heading = 6.0667 },
      { Pos = vector3(430.9147, -1026.6952, 28.8344), Heading = 5.9158 },
      { Pos = vector3(427.2970, -1027.0142, 28.9019), Heading = 6.3342 },
    },
    DeletePoint = {
      { Pos = vector3(446.0918, -1024.0363, 28.5160) },
      { Pos = vector3(442.3278, -1025.4196, 28.6097) },
      { Pos = vector3(438.3373, -1025.7689, 28.6909) },
      { Pos = vector3(434.7534, -1026.3446, 28.7670) },
      { Pos = vector3(430.9147, -1026.6952, 28.8344) },
      { Pos = vector3(427.2970, -1027.0142, 28.9019) },
    }
  },

  LSAirPort = {
    Label = 'Los Santos Airport',
    Type = 'aircraft',
    Blip = true,
    NotFree = true,
    Coords = vector3(-1122.4502, -2840.5667, 13.9458), 
    PedHeading = 152.0285,
    Players = {
      
    },
    Groups = {
      
    },
    SpawnPoint = {
      { Pos = vector3(-1178.2308, -2845.7175, 13.9458), Heading = 146.1286 },
      { Pos = vector3(-1145.8920, -2864.2798, 13.9460), Heading = 153.7971 },
      { Pos = vector3(-1112.4072, -2883.8889, 13.9460), Heading = 152.9144 },
    },
    DeletePoint = {
      { Pos = vector3(-1178.2308, -2845.7175, 13.9458) },
      { Pos = vector3(-1145.8920, -2864.2798, 13.9460) },
      { Pos = vector3(-1112.4072, -2883.8889, 13.9460) },
    }
  },
  
  MBAirport = {
    Label = 'Military Base Airport',
    Type = 'aircraft',
    Blip = true,
    NotFree = true,
    Coords = vector3(-2211.6267, 3167.5488, 32.8101), 
    PedHeading = 330.5554,
    Players = {
  
    },
    Groups = {
      
    },
    SpawnPoint = {
      { Pos = vector3(-2186.9236, 3172.0801, 32.8102), Heading = 326.1197 },
    },
    DeletePoint = {
      { Pos = vector3(-2186.9236, 3172.0801, 32.8102)},
    }
  },
  
  PacificOcean = {
    Label = 'Pacific Ocean Watercraft',
    Type = 'boat',
    Blip = true,
    NotFree = true,
    Coords = vector3(-1799.7592, -1225.0562, 1.5826), 
    PedHeading = 144.0511,
    Players = {
  
    },
    Groups = {
      
    },
    SpawnPoint = {
      { Pos = vector3(-1796.9568, -1229.5969, 0.2092), Heading = 145.8580 },
    },
    DeletePoint = {
      { Pos = vector3(-1796.9568, -1229.5969, 0.2092)},
    }
  },

}

Config.Impound = { -- Impound Config
	SandyShores = {
		Label = 'Sandy Shores Impound',
    Type = 'car',
    IsDefaultImpound = true,
		Blip = true,
    NotFree = true,
		Coords = vector3(252.6010, 2595.8438, 44.8995),
		PedHeading = 11.6176,
		SpawnPoint = {
			{ Pos = vector3(258.5054, 2590.7029, 44.4424), Heading = 10.3867, }
		},
	},

	SandyShoresAir = {
		Label = 'Sandy Shores Air',
    Type = 'aircraft',
    IsDefaultImpound = true,
		Blip = true,
    NotFree = true,
		Coords = vector3(1727.7544, 3293.1646, 41.1973),
		PedHeading = 193.5272,
		SpawnPoint = {
			{ Pos = vector3(1749.2124, 3264.2148, 41.2852), Heading = 102.5581, }
		},
	},

	SandyShoresBoat = {
		Label = 'Sandy Shores Watercraft',
    Type = 'boat',
    IsDefaultImpound = true,
		Blip = true,
    NotFree = true,
		Coords = vector3(1733.4327, 3985.1807, 31.9787),
		PedHeading = 121.1930,
		SpawnPoint = {
			{ Pos = vector3(1730.9972, 3990.8796, 29.7878), Heading = 304.6193, }
		},
	},

	JobsImpound = { -- if for jobs keywords should start with the word Jobs
		Label = 'Police Impound',
    Type = 'car',
    IsDefaultImpound = false,
		Blip = true,
    NotFree = false,
		Coords = vector3(409.5207, -1623.1407, 29.2919),
		PedHeading = 226.8043,
		SpawnPoint = {
			{ Pos = vector3(416.9999, -1627.8965, 29.0), Heading = 137.3000, },
			{ Pos = vector3(419.6365, -1629.6110, 29.0), Heading = 135.3693, },
			{ Pos = vector3(420.4732, -1635.9071, 29.0), Heading = 88.7233, },
			{ Pos = vector3(420.4871, -1638.9510, 29.0), Heading = 86.0705, },
			{ Pos = vector3(420.5472, -1641.9459, 29.0), Heading = 87.1742, },
		},
	},
}

Config.Blips = {
  Garages = {
    aircraft = {
      Sprite = 359,
      Colour = 3,
      Display = 2,
      Scale = 0.8
    },
    car = {
      Sprite = 357,
      Colour = 3,
      Display = 2,
      Scale = 0.8
    },
    boat = {
      Sprite = 356,
      Colour = 3,
      Display = 2,
      Scale =  0.8
    }
  },
  Impounds = {
    aircraft = {
      Sprite = 359,
      Colour = 51,
      Display = 2,
      Scale = 0.8
    },
    car = {
      Sprite = 477,
      Colour = 51,
      Display = 2,
      Scale = 0.7
    },
    boat = {
      Sprite = 356,
      Colour = 51,
      Display = 2,
      Scale =  0.8
    }
  }
}