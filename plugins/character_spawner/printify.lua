local spawn = require("./characterSpawner")
local serpent = require("./serpent")

return function(aliases)
	local data = { Aliases = {}, Assets = {} }

	for alias, record in pairs(aliases) do
		local manifest = record.manifest
		local accessories = {}
		local seen = {}

		for _, row in ipairs(manifest.Accessories) do
			local asset, hash = row.Asset, string.lower(row.Sha256)
			local existingHash = data.Assets[asset]
			if existingHash and existingHash ~= hash then
				return nil, string.format("[Character.Export]: Conflicting SHA-256 hashes for asset %s", asset)
			end
			data.Assets[asset] = hash

			if not seen[asset] then
				seen[asset] = true
				table.insert(accessories, asset)
			end
		end

		data.Aliases[alias] = {
			Appearance = spawn.GetAppearance(manifest),
			Accessories = accessories,
		}
	end

	local ok, source = pcall(serpent.block, data, {
		comment = false,
		fatal = true,
		indent = "    ",
		sortkeys = function(keys)
			table.sort(keys)
		end,
	})
	if not ok then
		return nil, "[Character.Export]: " .. tostring(source)
	end
	return "-- Save as scripts/CharacterData.lua\nreturn " .. source
end
