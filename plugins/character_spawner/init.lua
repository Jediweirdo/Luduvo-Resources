local json = require("./json")
local spawn = require("./characterSpawner")
local printify = require("./printify")
local aliases = {}

local numberFields = { user_id = true, item_id = true, rules = true }

local function decodeManifest(source)
	-- Studio has been screwing with me and stripping literally every quotation
	-- mark out of the json output  so now I'm stuck adding them all back
	-- And as in "me", I mean AI. This function was more or less AI generated
	-- For ledigibility, I also asked it to leave a comment denoting what each regex
	-- string did

    local ok, result = pcall(json.deserialize, source)
    if ok then return result end
    -- Look for an opening brace and an unquoted identifier followed by a colon.
    -- Allow whitespace around them, and skip recovery if any double quotes remain.
    if not source:match("^%s*{%s*[%a_][%w_]*%s*:") or source:find('"', 1, true) then
        error(result, 0)
    end

    -- Studio's command parser strips double quotes from string parameters.
    -- Recover simple avatar values using their field types, including large asset IDs.
    local tokens = {}
    local field
    -- Capture the text up to each brace, bracket, comma, or colon, then capture
    -- that delimiter separately. The extra comma catches any trailing text.
    for token, delimiter in (source .. ","):gmatch("([^{}%[%],:]*)([{}%[%],:])") do
        -- Trim leading and trailing whitespace. The minimal capture keeps internal spaces.
        token = token:match("^%s*(.-)%s*$")
        if delimiter == ":" then
            -- A key starts with a letter or underscore and can then contain digits too.
            if not token:match("^[%a_][%w_]*$") then error(result, 0) end
            field = token
            table.insert(tokens, json.serialize(token))
        else
            if token ~= "" then
                -- Reject backslashes because the original string escapes are ambiguous.
                if not field or token:find("\\", 1, true) then error(result, 0) end
                if numberFields[field] or token == "null" then
                    table.insert(tokens, token)
                else
                    table.insert(tokens, json.serialize(token))
                end
            end
            field = nil
        end
        table.insert(tokens, delimiter)
    end
    tokens[#tokens] = nil -- Drop the extra comma before decoding.
    return json.deserialize(table.concat(tokens))
end

plugin:Operator({
    Id = "character.register.json",
    Label = "Register",
    Params = {
        {
            Name = "json",
            Type = "string",
        },
        {
            Name = "alias",
            Type = "string",
            Default = "",
        },
    },
    Icon = "Assets/Icons/bruh.svg",
    Prefab = "Assets/Prefabs/Register.ldv",
    Execute = function(ctx, params)
        local ok, manifest = pcall(decodeManifest, params.json)
        if not ok then return false, `[Character.Register.Json]: Failed to deserialize JSON: {manifest}` end
        if not json.asObject(manifest) or type(manifest.user_id) ~= "number" then
            return false, "[Character.Register.Json]: Expected a numeric user_id"
        end

        local alias = if params.alias and params.alias ~= "" then params.alias else tostring(manifest.user_id)
        if aliases[alias] then return false, `[Character.Register.Json]: "{alias}" has already been registered` end

        local record, reason = spawn.fromAPI(manifest)
        if not record then return false, `[Character.Register.Json]: {reason}` end
        aliases[alias] = record

        return true
    end
})

plugin:Operator({
    Id = "character.spawn",
    Label = "Spawn",
    Params = {
        {
            Name = "alias",
            Type = "string",
        },
    },
    Icon = "Assets/Icons/stickFigure.svg",
    Prefab = "Assets/Prefabs/Spawn.ldv",
    Execute = function(ctx, params)
        local record = aliases[params.alias]
        if not record then return false,
            `[Character.Spawn]: "{params.alias}" hasn't been registered. Set it up with character.register.json first` end

        local targets = ctx.Selection
        local applied = false

        for _, target: Instance in targets do
            if not target:HasComponent("Character") then
                warn(`[Character.Spawn]: "{target.Name}" is not a character. Skipping.`)
                continue
            end
            spawn.Apply(ctx, record, target)
            applied = true
        end

        if not applied then return false, "[Character.Spawn]: Select a character rig first" end
        if #record.manifest.Accessories > 0 then
            warn("[Character.Spawn]: Studio plugins cannot fetch accessories in edit mode. Applied body and clothing.")
        end
        return true
    end
})

plugin:Operator({
    Id = "character.export",
    Label = "Export Avatar Data",
    Params = {
        { Name = "output", Type = "string", Default = "console", Hidden = true },
    },
    Icon = "Assets/Icons/bruh.svg",
    Execute = function(ctx, params)
    	params.output = string.lower(params.output)

    	if params.output and not table.find({"console", "ui"}, params.output) then
            return false, `[Character.Export]: Only "console" and "ui" are acceptable output types!`
        end

        if #aliases == 0 then
            return false, "[Character.Export]: There is nothing to export! Register a character before exporting"
        end
        local source, reason = printify(aliases)

        if not source then return false, reason end

        if params.output == "console" then
        	print(source)
        elseif params.output == "ui" then
        	ctx.Edit:Create("later :p")
        end

        return true
    end
})

plugin:Ribbon({Group = "Character", Items = {"character.register.json", "character.spawn", "character.export"}})
