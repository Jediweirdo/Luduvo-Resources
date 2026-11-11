local json = require("./json")
local spawn = require("./characterSpawner")
local aliases = {}

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
    	print(params.json)
        local ok, manifest = pcall(json.deserialize, params.json)
        if not ok then return false, `[Character.Register.Json]: Failed to deserialize JSON: {manifest}` end
        if not manifest.user_id then return false, `[Character.Register.Json]: JSON Missing Required Field: user_id` end

        local alias = if params.alias ~= "" then params.alias else manifest.user_id
        if aliases[alias] then return false, `[Character.Register.Json]: "{alias}" has already been registered` end

        aliases[alias] = manifest.user_id

        local record = spawn.fromAPI(manifest)
        if not record then return false, "[Character.Register.Json]: fromAPI returned nothing somehow" end

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
        {
            Name = "targets",
            Type = "instances",
            From = "Selection",
        }
    },
    Icon = "Assets/Icons/stickFigure.svg",
    Prefab = "Assets/Prefabs/Spawn.ldv",
    Execute = function(ctx, params)
        local id = aliases[params.alias]
        if not id then return false,
            `[Character.Spawn]: "{params.alias}" hasn't been registered. Set it up with character.register.json first` end

        local charRecord = spawn.GetRecord(id)
        if not charRecord then return false, `[Character.Spawn]: "{params.alias}" doesn't have a record (this is a bug)` end

        if not params.targets then params.targets = ctx.Edit:Create("Character") end

        for _, target: Instance in params.targets do
        	if not target:HasComponent("Character") then warn(`[Character.Spawn]: "{target.Name} is not a character! Skipping..."`) ; continue end
            spawn.Apply(id, target)
        end

        return true
    end
})

plugin:Ribbon({Group = "Character", Items = {"character.register.json", "character.spawn"}})
