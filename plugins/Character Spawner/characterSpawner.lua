-- Avatar: dress a character the way the account says.
--
-- The engine hands us the manifest (game.Content.Avatar) and a
-- validated fetch lane (game.Content.Fetch, then AddAccessory with
-- the handle the fetch produced).  Everything about *which* avatar
-- is worn lives here, in a script a place can read, copy, or replace.
-- The script states intent only: it writes CharacterAppearance on
-- the character root and wears accessories; the client resolves
-- meshes, colours, and the face from that component.
--
-- One record per player holds the manifest, every request still in
-- flight, and a generation number.  A callback checks the generation
-- it was issued under and drops out if the player left, the character
-- respawned, or a newer manifest arrived; the requests themselves are
-- cancelled at those moments so the engine stops the work too.

-- This is basically just Luduvo's Avatar spawner but generalized to work outside of runtime

local PART_NAMES = { "Head", "Torso", "LeftArm", "RightArm", "LeftLeg",
		     "RightLeg" }
local BODY_PROPERTIES = { "BodyHead", "BodyTorso", "BodyLeftArm",
			  "BodyRightArm", "BodyLeftLeg", "BodyRightLeg" }
local COLOR_PROPERTIES = { "BodyColorHead", "BodyColorTorso",
			   "BodyColorLeftArm", "BodyColorRightArm",
			   "BodyColorLeftLeg", "BodyColorRightLeg" }

local FETCH_IN_FLIGHT_MAX = 16
local FETCH_RETRY_SECONDS = 0.5
local NO_ASSET = "0"

local records = {}
local wornAssets = {}
local fetchesInFlight = 0
local retryTask = nil
local pumpFetches

local Spawner = {}

local function recordOf(id, failIfMissing)
	local record = records[id]
	if record == nil then
		if failIfMissing then return nil end
		record = { manifest = nil, wantedAssets = nil,
			   answered = false, request = nil, generation = 0,
			   character = nil, backlog = {}, nextRow = 1,
			   fetches = {} }
		records[id] = record
	end
	return record
end

local function cancelFetches(record)
	record.generation += 1
	for _, fetch in record.fetches do
		fetch:Cancel()
		fetchesInFlight -= 1
	end
	table.clear(record.fetches)
	table.clear(record.backlog)
	record.nextRow = 1
end

local function wear(character, record, row)
	local generation = record.generation
	local asset = row.Asset
	local ok, fetch = pcall(game.Content.Fetch, asset, row.Sha256,
		function(handle, reason)
			if record.generation ~= generation then
				return
			end
			record.fetches[asset] = nil
			fetchesInFlight -= 1
			if handle == nil then
				warn("Avatar: accessory " .. asset
				     .. " not worn: " .. tostring(reason))
			elseif character:IsAlive()
			       and character:AddAccessory(handle) == nil then
				warn("Avatar: accessory " .. asset
				     .. " did not attach")
			end
			pumpFetches(character)
		end)
	if not ok then
		local message = tostring(fetch)
		if string.find(message, "queue is full", 1, true) == nil then
			error(message, 0)
		end
		return false
	end
	record.fetches[asset] = fetch
	fetchesInFlight += 1
	return true
end

local function retryFetches(character)
	retryTask = nil
	pumpFetches(character)
end

function pumpFetches(character)
	for _, record in records do
		local backlog = record.backlog
		while record.nextRow <= #backlog do
			if fetchesInFlight >= FETCH_IN_FLIGHT_MAX then
				return
			end
			if not wear(record, backlog[record.nextRow]) then
				if retryTask == nil then
					retryTask = task.delay(FETCH_RETRY_SECONDS,
							       retryFetches, character)
				end
				return
			end
			record.nextRow += 1
		end
	end
end

function Spawner.Apply(ctx: PluginContext, record, character)
	local manifest = record.manifest
	local charDraft = {}

	if not manifest then return end

	for partIndex, name in PART_NAMES do
		local mesh = manifest.Body[name]
		if mesh ~= nil then
			charDraft[BODY_PROPERTIES[partIndex]] = mesh
		end
		local color = manifest.BodyColors[name]
		if color ~= nil then
			charDraft[COLOR_PROPERTIES[partIndex]] = color
		end
	end
	if manifest.Face ~= nil then
		charDraft.Face = manifest.Face
	end
	if manifest.Shirt ~= nil then
		charDraft.Shirt = manifest.Shirt
	end
	if manifest.Pants ~= nil then
		charDraft.Pants = manifest.Pants
	end

	local wantedAssets = record.wantedAssets
	table.clear(wornAssets)
	for accessory in game.World.Each(game.World.Pair("WornBy", character)) do
		local asset = accessory.Asset
		if asset == NO_ASSET then
			continue
		end
		if wantedAssets[asset] == nil or wornAssets[asset] then
			accessory:Destroy()
		else
			wornAssets[asset] = true
		end
	end
	for _, row in manifest.Accessories do
		if not wornAssets[row.Asset] then
			wornAssets[row.Asset] = true
			table.insert(record.backlog, row)
		end
	end

	for k, v in charDraft do
		ctx.Edit:Set(character, k, v)
	end
	pumpFetches(character)
end

function Spawner.fromAPI(endpoint)
    local record = recordOf(endpoint.user_id)
    if record.answered or record.request ~= nil then
		return record
	end

    local manifest = {
        Accessories = {},
        Body = endpoint.body,
        BodyColors = endpoint.body_colors,
        Face = endpoint.face_decal,
        Pants = endpoint.pants,
        Shirt = endpoint.shirt
    }
    for i, row in endpoint.accessories do
        local CapitalizedRow = {}
        for name, item in row do
            CapitalizedRow[name:gsub("^%l", string.upper)] = item
        end
        manifest.Accessories[i] = CapitalizedRow
    end


    record.answered = true
	record.manifest = manifest
	record.wantedAssets = {}
	for _, row in manifest.Accessories do
		record.wantedAssets[row.Asset] = true
	end

	record.request = "blahblahblah"

	return record
end

-- Lying in wait until game.Content.Avatar allows userIds
function Spawner.fromUserId(id)
    local record = recordOf(id)
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
		record.wantedAssets = {}
		for _, row in manifest.Accessories do
			record.wantedAssets[row.Asset] = true
		end
	end)
	record.request = request
	return record
end

function Spawner.GetRecord(id)
	return recordOf(id, true)
end

return Spawner
