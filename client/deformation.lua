local MDI = 50
local DDT = 0.05

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
