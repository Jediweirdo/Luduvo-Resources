-- This is basically just Luduvo's Avatar spawner but generalized to work without needing a player
-- This REQUIRES you to register characters in Studio via the plugin first!!!

local data = require("./AvatarData") --  Put all the avatar data here if you are using the exporter
local Dresser = {}
local TAG = "Dress Up" -- This tag will activate the dresser to dress your character
local watched = {}

local FETCH_IN_FLIGHT_MAX = 16
local FETCH_RETRY_SECONDS = 0.5

local records = {}
local fetchesInFlight = 0
local retryTask = nil
local pumpFetches

local function cancelFetches(record)
	record.generation += 1
	for _, fetch in record.fetches do
		fetch:Cancel()
		fetchesInFlight -= 1
	end
	table.clear(record.fetches)
	table.clear(record.backlog)
	record.nextRow = 1
	record.character = nil
end

local function removeUnused(record, wanted)
	for asset, accessory in record.owned do
		if not accessory:IsAlive() then
			record.owned[asset] = nil
		elseif not wanted[asset] then
			accessory:Destroy()
			record.owned[asset] = nil
		end
	end
end

local function isCurrent(record)
	local character = record.character
	if not character:IsAlive() or not character:HasComponent("Character")
		or character:HasComponent("CharacterDead") then
		return false
	end
	if record.tag and (not character:HasComponent(record.tag) or character.attr.AvatarAlias ~= record.alias) then
		record.interrupted = true
		return false
	end
	return true
end

local function wear(record, row)
	local character = record.character
	local generation = record.generation
	local asset = row.Asset
	local ok, fetch = pcall(game.Content.Fetch, asset, row.Sha256,
		function(handle, reason)
			if record.generation ~= generation then
				return
			end
			record.fetches[asset] = nil
			fetchesInFlight -= 1
			if isCurrent(record) then
				if handle == nil then
					warn("AvatarDresser: accessory " .. asset
					     .. " not worn: " .. tostring(reason))
				else
					local worn = false
					for accessory in game.World.Each(game.World.Pair("WornBy", character)) do
						if accessory.Asset == asset then
							worn = true
							break
						end
					end
					if not worn then
						local attached, accessory = pcall(character.AddAccessory, character, handle)
						if attached and accessory then
							record.owned[asset] = accessory
						else
							warn("AvatarDresser: accessory " .. asset .. " did not attach: " .. tostring(accessory))
						end
					end
				end
			end
			pumpFetches()
		end)
	if not ok then
		local message = tostring(fetch)
		if string.find(message, "queue is full", 1, true) == nil then
			warn("AvatarDresser: accessory " .. asset .. " could not be requested: " .. message)
			return true
		end
		return false
	end
	record.fetches[asset] = fetch
	fetchesInFlight += 1
	return true
end

local function retryFetches()
	retryTask = nil
	pumpFetches()
end

function pumpFetches()
	for _, record in records do
		if not isCurrent(record) then continue end
		local backlog = record.backlog
		while record.nextRow <= #backlog do
			if fetchesInFlight >= FETCH_IN_FLIGHT_MAX then
				return
			end
			if not wear(record, backlog[record.nextRow]) then
				if retryTask == nil then
					retryTask = task.delay(FETCH_RETRY_SECONDS,
							       retryFetches)
				end
				return
			end
			record.nextRow += 1
		end
	end
end

local function apply(character, alias, fullAppearance, tag)
	if not character:IsAlive() or not character:HasComponent("Character") or character:HasComponent("CharacterDead") then
		return false, "Expected a live character"
	end
	local avatar = data.Aliases[alias]
	if not avatar then
		return false, `Unknown avatar alias "{alias}"`
	end

	local wanted = {}
	for _, asset in avatar.Accessories do
		if not data.Assets[asset] then
			return false, `Missing SHA-256 hash for asset {asset}`
		end
		wanted[asset] = true
	end
	if fullAppearance then
		for property, value in avatar.Appearance do
			character[property] = if property:match("^BodyColor") then Color3.fromHex(value) else value
		end
	end

	local previous = records[character]
	if previous and previous.alias == alias and previous.tag == tag and not previous.interrupted
		and (previous.nextRow <= #previous.backlog or next(previous.fetches) ~= nil) then
		return true
	end
	if previous then cancelFetches(previous) end
	local state = {
		alias = alias,
		tag = tag,
		owned = if previous then previous.owned else {},
		character = character,
		backlog = {},
		nextRow = 1,
		fetches = {},
		generation = 0,
	}
	records[character] = state
	removeUnused(state, wanted)

	local worn = {}
	for accessory in game.World.Each(game.World.Pair("WornBy", character)) do
		worn[accessory.Asset] = true
	end
	for _, asset in avatar.Accessories do
		if not worn[asset] then
			worn[asset] = true
			table.insert(state.backlog, { Asset = asset, Sha256 = data.Assets[asset] })
		end
	end
	pumpFetches()
	return true
end

function Dresser.Apply(character, alias, fullAppearance)
	return apply(character, alias, fullAppearance, nil)
end

local function reconcileTagged(current, tag)
	for character, alias in current do
		local state = records[character]
		if not character:IsAlive() or not character:HasComponent(tag) or character.attr.AvatarAlias ~= alias then
			current[character] = nil
		elseif watched[character] ~= alias or (state and state.interrupted) then
			local ok, reason = apply(character, alias, false, tag)
			if not ok then warn(`[AvatarDresser]: {reason}`) end
		end
	end
	watched = current

	for character, state in records do
		if not character:IsAlive() or character:HasComponent("CharacterDead") then
			cancelFetches(state)
			records[character] = nil
		elseif state.tag and current[character] ~= state.alias then
			cancelFetches(state)
			removeUnused(state, {})
			records[character] = nil
		end
	end
	pumpFetches()
end

function Dresser.Activate()
	local tag = game.World.Pair("Tag", TAG)
	local query = game.World:Query("Character", tag):Without("CharacterDead")
	game.World:System("Dresser", query, function(q)
		local current = {}
		local changed = false
		for i = 1, q.count do
			local character = q.Instance[i]
			if not character then continue end
			local alias = character.attr.AvatarAlias
			if type(alias) == "string" and alias ~= "" then
				current[character] = alias
				local record = records[character]
				if watched[character] ~= alias or (record and record.interrupted) then
					changed = true
				end
			end
		end
		for character in watched do
			if not current[character] then changed = true end
		end
		for character in records do
			if not character:IsAlive() or character:HasComponent("CharacterDead") then changed = true end
		end
		if changed then task.defer(reconcileTagged, current, tag) end
	end)
end

return Dresser
