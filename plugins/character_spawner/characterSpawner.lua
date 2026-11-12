local json = require("./json")

local PART_NAMES = { "Head", "Torso", "LeftArm", "RightArm", "LeftLeg",
		     "RightLeg" }
local API_PART_NAMES = { "head", "torso", "left_arm", "right_arm", "left_leg", "right_leg" }
local BODY_PROPERTIES = { "BodyHead", "BodyTorso", "BodyLeftArm",
			  "BodyRightArm", "BodyLeftLeg", "BodyRightLeg" }
local COLOR_PROPERTIES = { "BodyColorHead", "BodyColorTorso",
			   "BodyColorLeftArm", "BodyColorRightArm",
			   "BodyColorLeftLeg", "BodyColorRightLeg" }

local records = {}
local Spawner = {}

function Spawner.GetAppearance(manifest)
	local appearance = {}
	for partIndex, name in PART_NAMES do
		local mesh = manifest.Body[name]
		if mesh ~= nil then
			appearance[BODY_PROPERTIES[partIndex]] = mesh
		end
		local color = manifest.BodyColors[name]
		if color ~= nil then
			appearance[COLOR_PROPERTIES[partIndex]] = color
		end
	end
	appearance.Face = manifest.Face
	appearance.Shirt = manifest.Shirt
	appearance.Pants = manifest.Pants
	return appearance
end

function Spawner.Apply(ctx: PluginContext, record, character)
	for property, value in Spawner.GetAppearance(record.manifest) do
		if property:match("^BodyColor") and type(value) == "string" then
			value = Color3.fromHex(value)
		end
		ctx.Edit:Set(character, property, value)
	end
end

function Spawner.fromAPI(endpoint)
	local manifest = { Accessories = {}, Body = {}, BodyColors = {} }
	local body = json.asObject(endpoint.body) or {}
	local colors = json.asObject(endpoint.body_colors) or {}

	for i, key in API_PART_NAMES do
		local mesh, color = body[key], colors[key]
		if type(mesh) == "string" then
			manifest.Body[PART_NAMES[i]] = mesh
		end
		if type(color) == "string" then
			if not color:match("^#?%x%x%x%x%x%x$") then
				return nil, `Invalid body color for {key}`
			end
			manifest.BodyColors[PART_NAMES[i]] = color
		end
	end
	manifest.Face = if type(endpoint.face_decal) == "string" then endpoint.face_decal else nil
	manifest.Shirt = if type(endpoint.shirt) == "string" then endpoint.shirt else nil
	manifest.Pants = if type(endpoint.pants) == "string" then endpoint.pants else nil

	for _, row in json.asArray(endpoint.accessories) or {} do
		if not json.asObject(row) or type(row.asset) ~= "string" or not row.asset:match("^%d+$")
			or type(row.sha256) ~= "string" or #row.sha256 ~= 64 or not row.sha256:match("^%x+$") then
			return nil, "Expected an accessory asset ID and SHA-256 hash"
		end
		table.insert(manifest.Accessories, { Asset = row.asset, Sha256 = row.sha256 })
	end

	local record = { manifest = manifest, answered = true }
	records[endpoint.user_id] = record
	return record
end

-- Lying in wait until game.Content.Avatar allows userIds
function Spawner.fromUserId(id)
	local record = records[id] or {}
	records[id] = record
	if record.answered or record.request ~= nil then
		return
	end
	local request
	request = game.Content.Avatar(id, function(manifest, reason)
		if record.request ~= request then
			return
		end
		record.request = nil
		if manifest == nil then
			error(`[Character Spawner]: no manifest for "{id}": {reason or "¯\_(ツ)_/¯"}`)
		end
		record.answered = true
		record.manifest = manifest
	end)
	record.request = request
	return record
end

function Spawner.GetRecord(id)
	return records[id]
end

return Spawner
