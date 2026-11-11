local RAINBOW_MATERIAL_TAG = "rainbow outline"
local RAINBOW_MATERIAL_EXCLUDE_TAG = "processed rainbow outline"
local RAINBOW_SHADER_NAME = "Rainbow_Outline"
local MATERIAL_ID_OFFSET = "2810246167479189504" -- only change if you know that its right or your game will have a giant lag spike
local MATERIAL_ID_RETRIES = 1000
local RAINBOW_EVERYTHING = false
local RAINBOW_MATERIAL_TRACKER_PARENT = game.World

local nextMaterialId = MATERIAL_ID_OFFSET
local allRainbowMaterials = game.World.Query("SurfaceMaterial"):Without(game.World.Pair("Tag", RAINBOW_MATERIAL_EXCLUDE_TAG))
if not RAINBOW_EVERYTHING then
    allRainbowMaterials = allRainbowMaterials:With(game.World.Pair("Tag", RAINBOW_MATERIAL_TAG))
end

local rainbowTracker = Instance.new()
local idRetries = 0
rainbowTracker.Name = "RainbowTracker"
rainbowTracker.Parent = assert(RAINBOW_MATERIAL_TRACKER_PARENT)

local function incrementDecimal(id: string): string
    local i = #id
    while i > 0 and id:sub(i, i) == "9" do
        i -= 1
    end

    if i == 0 then
        return "1" .. string.rep("0", #id)
    end

    local digit = tonumber(id:sub(i, i))
    return id:sub(1, i - 1) .. tostring(digit + 1) .. string.rep("0", #id - i)
end

game.World.System("RainbowApplier", allRainbowMaterials, function(query: Query, _)
	for i = 1, query.count do
		local materialComponent: SurfaceMaterialComponent = query.SurfaceMaterial[i]
		local ok, material = pcall(game.Materials.GetMaterial, materialComponent.Material)
		if not ok or not material then
		    warn(`RainbowApplier: Material for Instance {query.Instance[i].Name} returned "{material}" instead of a valid material name`)
			query.Entity[i]:AddComponent(game.World.Pair("Tag", RAINBOW_MATERIAL_EXCLUDE_TAG))
			continue
		end

		if material.Shader ~= RAINBOW_SHADER_NAME then
		    local err

		    material.Shader = RAINBOW_SHADER_NAME

			while ok do
				nextMaterialId = incrementDecimal(nextMaterialId)
				ok, err = pcall(game.Materials.GetMaterial, nextMaterialId)
				idRetries += 1
				if idRetries > MATERIAL_ID_RETRIES then
					warn(`RainbowApplier: Failed to find a free material ID after {MATERIAL_ID_RETRIES} retries ({err})`)
					break
				end
			end
			if not ok then
				warn(`RainbowApplier: Failed to define material {nextMaterialId} ({err})`)
				query.Entity[i]:AddComponent(game.World.Pair("Tag", RAINBOW_MATERIAL_EXCLUDE_TAG))
				continue
			end

			idRetries = 0
			material.Name += `_RAINBOW_{nextMaterialId}` -- just in case it isn't unique
			material.Id = `{nextMaterialId}`
			ok, material = pcall(game.Materials.DefineMaterial, material)

			if not ok then
				warn(`RainbowApplier: Failed to define material {nextMaterialId} ({err})`)
				query.Entity[i]:AddComponent(game.World.Pair("Tag", RAINBOW_MATERIAL_EXCLUDE_TAG))
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
