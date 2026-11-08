local RAINBOW_MATERIAL_TAG = "rainbow outline"
local RAINBOW_MATERIAL_EXCLUDE_TAG = "processed rainbow outline"
local RAINBOW_SHADER_NAME = "Rainbow_Outline"
local MATERIAL_ID_OFFSET = 12345 -- only change if you know that its right or your game will have a giant lag spike
local RAINBOW_EVERYTHING = false
local RAINBOW_MATERIAL_TRACKER_PARENT = game.World
local SKIP_ON_ERROR = false

local nextMaterialId = MATERIAL_ID_OFFSET + 1

local allRainbowMaterials = game.World.Query("SurfaceMaterial"):Without(game.World.Pair("Tag", RAINBOW_MATERIAL_EXCLUDE_TAG))
if not RAINBOW_EVERYTHING then
    allRainbowMaterials = allRainbowMaterials:With(game.World.Pair("Tag", RAINBOW_MATERIAL_TAG))
end

local rainbowTracker = Instance.new()
rainbowTracker.Name = "RainbowTracker"
rainbowTracker.Parent = assert(RAINBOW_MATERIAL_TRACKER_PARENT)

game.World.System("RainbowApplier", allRainbowMaterials, function(query: Query, _)
	for i = 1, query.count do
		local materialComponent: SurfaceMaterialComponent = query.SurfaceMaterial[i]
		local ok, material = pcall(game.Materials.GetMaterial, materialComponent.Material)
		if not ok or not material then
		    warn(`RainbowApplier: Material for Instance {query.Instance[i].Name} returned "{material}" instead of a valid material name`)
			if SKIP_ON_ERROR then
				query.Entity[i]:AddComponent(game.World.Pair("Tag", RAINBOW_MATERIAL_EXCLUDE_TAG))
			end

			continue
		end

		if material.Shader ~= RAINBOW_SHADER_NAME then

		    material.Shader = RAINBOW_SHADER_NAME

			while ok do
				nextMaterialId += 1
				ok, _ = pcall(game.Materials.GetMaterial, `{nextMaterialId}`)
			end

			material.Name += `_RAINBOW_{nextMaterialId}` -- just in case it isn't unique
			material.Id = `{nextMaterialId}`
			ok, material = pcall(game.Materials.DefineMaterial, material)

			if not ok then
				warn(`RainbowApplier: {material}`)
				if SKIP_ON_ERROR then
					query.Entity[i]:AddComponent(game.World.Pair("Tag", RAINBOW_MATERIAL_EXCLUDE_TAG))
				end

				continue
			end

			materialComponent.Material = material
		end

		if not rainbowTracker.attr[materialComponent.Material] then
			rainbowTracker.attr[materialComponent.Material] = true
		end

		query.Entity[i]:AddComponent(game.World.Pair("Tag", RAINBOW_MATERIAL_EXCLUDE_TAG))
	end
end)
