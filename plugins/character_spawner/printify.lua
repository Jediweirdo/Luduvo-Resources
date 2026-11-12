local spawn = require("./characterSpawner")

local function sortKeys(dictionary)
	local keys = {}
	for key in dictionary do
		table.insert(keys, key)
	end
	table.sort(keys)
	return keys
end

return function(aliases)
	local lines = { "-- Save as scripts/AvatarData.lua", "return {", "\tAliases = {" }
	local assets = {}

	for _, alias in sortKeys(aliases) do
		local manifest = aliases[alias].manifest
		local appearance = spawn.GetAppearance(manifest)

		table.insert(lines, string.format("\t\t[%q] = {", alias))
		table.insert(lines, "\t\t\tAppearance = {")

		for _, property in sortKeys(appearance) do
			table.insert(lines, string.format("\t\t\t\t%s = %q,", property, appearance[property]))
		end

		table.insert(lines, "\t\t\t},")
		table.insert(lines, "\t\t\tAccessories = {")

		local seen = {}
		for _, row in manifest.Accessories do
			local asset, hash = row.Asset, string.lower(row.Sha256)

			if assets[asset] and assets[asset] ~= hash then
				return nil, `[Character.Export]: Conflicting SHA-256 hashes for asset {asset}`
			end
			assets[asset] = hash

			if not seen[asset] then
				seen[asset] = true
				table.insert(lines, string.format("\t\t\t\t%q,", asset))
			end
		end

		table.insert(lines, "\t\t\t},")
		table.insert(lines, "\t\t},")
	end

	table.insert(lines, "\t},")
	table.insert(lines, "\tAssets = {")

	for _, asset in sortKeys(assets) do
		table.insert(lines, string.format("\t\t[%q] = %q,", asset, assets[asset]))
	end

	table.insert(lines, "\t},")
	table.insert(lines, "}")

	return table.concat(lines, "\n")
end
