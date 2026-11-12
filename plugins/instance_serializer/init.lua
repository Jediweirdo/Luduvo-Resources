local printify = require("./serpent")
local propertyDB = require("./property_names")

function normalizeField(componentName, field)
	local qualifiedName = componentName .. "." .. field
	local newField = propertyDB.propertyNames[qualifiedName] or propertyDB.propertyNames[field]
	local skipCheck = propertyDB.unmappedComponentFields[qualifiedName]
		or (not newField and propertyDB.unmappedComponentFields[field])
	if skipCheck then
		if skipCheck.warn then
			warn(`[Instance.Serialize]: Unable to serialize field from "{componentName}": {skipCheck.reason}`)
		end
		return
	end

	if not newField then
		return warn(
			`[Instance.Serialize]: Unable to serialize field from "{componentName}": {field} isn't a dumped field`
		)
	end

	return newField
end

function normalizeName(instance: Instance?, descendants: { Instance })
	if not instance then
		return
	end

	local name = instance.Name or "Unknown"

	local cleaned = name:gsub("[^A-Za-z0-9_]", "_")
	local index = table.find(descendants, instance)
	if not index then
		return warn(
			`[Instance.Serialize]: {instance.Name or "An unnamed instance"} is not apart of the selected exports!`
		)
	end

	return cleaned .. index
end

function spawnOutputUi(ctx: PluginContext, output: string)
	local Export1 = ctx.Edit:Create("Folder", {
		AnchorPoint = Vector3.new(0, 0, 0),
		AspectRatio = 0,
		LayoutOrder = 0,
		MaxSize = UDim2.new(0, 0, 0, 0),
		MinSize = Vector3.new(0, 0, 0),
		Name = "Export",
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		SizeModeX = "Fixed",
		SizeModeY = "Fixed",
		UIRoot = true,
		ZIndex = 32003,
	})

	local Box2 = ctx.Edit:Create("Folder", {
		Align = "Start",
		AnchorPoint = Vector3.new(0.5, 0.5, 0),
		AspectRatio = 0,
		Axis = "Vertical",
		BackgroundColor3 = Vector3.new(0.2160000056028366, 0.21899999678134918, 0.2240000069141388),
		BackgroundTransparency = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ClipsDescendants = true,
		CornerRadius = 8,
		Justify = "Start",
		LayoutOrder = 0,
		MarginBottom = 24,
		MarginLeft = 24,
		MarginRight = 24,
		MarginTop = 24,
		MaxSize = UDim2.new(1, -32, 1, -32),
		MinSize = Vector3.new(0, 0, 0),
		Name = "Box",
		Position = UDim2.new(0.5, 0, 0.5, -14.5),
		Selectable = false,
		SelectionGroup = true,
		Size = UDim2.new(0, 400, 0, 325.990234375),
		SizeModeX = "Fixed",
		SizeModeY = "Fit",
		Spacing = 16,
		UIClickable = true,
		ZIndex = 32000,
	}, Export1)

	local Title3 = ctx.Edit:Create("Folder", {
		AnchorPoint = Vector3.new(0, 0, 0),
		AspectRatio = 0,
		FontFamily = "Arimo",
		FontWeight = 700,
		Italic = false,
		LayoutOrder = 0,
		MaxSize = UDim2.new(0, 0, 0, 0),
		MinSize = Vector3.new(0, 0, 0),
		Name = "Title",
		NoTranslate = false,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 28),
		SizeModeX = "Fixed",
		SizeModeY = "Fit",
		Text = "Export",
		TextColor3 = Vector3.new(0.9430000185966492, 0.9480000138282776, 0.9570000171661377),
		TextSize = 20,
		TextStrokeColor3 = Vector3.new(0, 0, 0),
		TextStrokeScale = 0,
		TextStrokeTransparency = 1,
		TextStrokeWidth = 0,
		TextTransparency = 0,
		TextWrapped = true,
		TextXAlignment = "Center",
		TextYAlignment = "Center",
		ZIndex = 32000,
	}, Box2)

	local Instructions4 = ctx.Edit:Create("Folder", {
		AnchorPoint = Vector3.new(0, 0, 0),
		AspectRatio = 0,
		FontFamily = "Arimo",
		FontWeight = 400,
		Italic = false,
		LayoutOrder = 2,
		MaxSize = UDim2.new(0, 0, 0, 0),
		MinSize = Vector3.new(0, 0, 0),
		Name = "Instructions",
		NoTranslate = false,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 24),
		SizeModeX = "Fixed",
		SizeModeY = "Fit",
		Text = "Copy/Paste the textbox below into your scripts and it should just work. Feel free to delete this instance when you're done",
		TextColor3 = Vector3.new(0.7843137383460999, 0.800000011920929, 0.8235294222831726),
		TextSize = 16,
		TextStrokeColor3 = Vector3.new(0, 0, 0),
		TextStrokeScale = 0,
		TextStrokeTransparency = 1,
		TextStrokeWidth = 0,
		TextTransparency = 0,
		TextWrapped = true,
		TextXAlignment = "Center",
		TextYAlignment = "Center",
		ZIndex = 32000,
	}, Box2)

	local Instructions5 = ctx.Edit:Create("Folder", {
		AnchorPoint = Vector3.new(0, 0, 0),
		AspectRatio = 0,
		FontFamily = "Arimo",
		FontWeight = 400,
		Italic = false,
		LayoutOrder = 3,
		MaxSize = UDim2.new(0, 0, 0, 0),
		MinSize = Vector3.new(0, 0, 0),
		Name = "Instructions",
		NoTranslate = false,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 24),
		SizeModeX = "Fixed",
		SizeModeY = "Fit",
		Text = 'In the future, you can set the "output" param to console and then you won\'t have to do this anymore',
		TextColor3 = Vector3.new(0.7843137383460999, 0.800000011920929, 0.8235294222831726),
		TextSize = 16,
		TextStrokeColor3 = Vector3.new(0, 0, 0),
		TextStrokeScale = 0,
		TextStrokeTransparency = 1,
		TextStrokeWidth = 0,
		TextTransparency = 0,
		TextWrapped = true,
		TextXAlignment = "Center",
		TextYAlignment = "Center",
		ZIndex = 32000,
	}, Box2)

	local Instructions6 = ctx.Edit:Create("Folder", {
		AnchorPoint = Vector3.new(0, 0, 0),
		AspectRatio = 0,
		FontFamily = "Arimo",
		FontWeight = 400,
		Italic = false,
		LayoutOrder = 5,
		MaxSize = UDim2.new(0, 0, 0, 0),
		MinSize = Vector3.new(0, 0, 0),
		Name = "Instructions",
		NoTranslate = false,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 24),
		SizeModeX = "Fixed",
		SizeModeY = "Fit",
		Text = "This is specifically for plugin development and usless for anything else. Use a prefab if you can :)",
		TextColor3 = Vector3.new(0.7843137383460999, 0.800000011920929, 0.8235294222831726),
		TextSize = 16,
		TextStrokeColor3 = Vector3.new(0, 0, 0),
		TextStrokeScale = 0,
		TextStrokeTransparency = 1,
		TextStrokeWidth = 0,
		TextTransparency = 0,
		TextWrapped = true,
		TextXAlignment = "Center",
		TextYAlignment = "Center",
		ZIndex = 32000,
	}, Box2)

	local Instance_Output7 = ctx.Edit:Create("Folder", {
		Align = "Center",
		AnchorPoint = Vector3.new(0, 0, 0),
		AspectRatio = 0,
		Axis = "Horizontal",
		Justify = "Start",
		LayoutOrder = 4,
		MarginBottom = 0,
		MarginLeft = 0,
		MarginRight = 0,
		MarginTop = 0,
		MaxSize = UDim2.new(0, 0, 0, 0),
		MinSize = Vector3.new(0, 0, 0),
		Name = "Instance Output",
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 138),
		SizeModeX = "Fixed",
		SizeModeY = "Fixed",
		Spacing = 12,
		ZIndex = 32000,
	}, Box2)

	local Field8 = ctx.Edit:Create("Folder", {
		Align = "Center",
		AnchorPoint = Vector3.new(0, 0, 0),
		AspectRatio = 0,
		Axis = "Vertical",
		BackgroundColor3 = Vector3.new(0.9430000185966492, 0.9480000138282776, 0.9570000171661377),
		BackgroundTransparency = 0.93999999761581421,
		BorderColor3 = Vector3.new(0.14509804546833038, 0.38823530077934265, 0.9215686321258545),
		BorderFocusOnly = true,
		BorderSizePixel = 2,
		BorderTransparency = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ClipsDescendants = true,
		CornerRadius = 4,
		Justify = "Start",
		LayoutOrder = 1,
		MarginBottom = 0,
		MarginLeft = 12,
		MarginRight = 12,
		MarginTop = 12,
		MaxSize = UDim2.new(0, 0, 1, 0),
		MinSize = Vector3.new(0, 0, 0),
		Name = "Field",
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		SizeModeX = "Fixed",
		SizeModeY = "Fixed",
		Spacing = 0,
		ZIndex = 32000,
	}, Instance_Output7)

	local instance9 = ctx.Edit:Create("Folder", {
		AnchorPoint = Vector3.new(0, 0, 0),
		AspectRatio = 0,
		Cursor = "Text",
		FontFamily = "Arimo",
		FontWeight = 400,
		Italic = false,
		LayoutOrder = 0,
		MaxSize = UDim2.new(0, 0, 0, 0),
		MinSize = Vector3.new(0, 0, 0),
		Name = "instance",
		NoTranslate = false,
		Position = UDim2.new(0, 0, 0, 40),
		Size = UDim2.new(1, 0, 0, 552),
		SizeModeX = "Fixed",
		SizeModeY = "Fixed",
		Text = output,
		TextColor3 = Vector3.new(0.9430000185966492, 0.9480000138282776, 0.9570000171661377),
		TextSize = 16,
		TextStrokeColor3 = Vector3.new(0, 0, 0),
		TextStrokeScale = 0,
		TextStrokeTransparency = 1,
		TextStrokeWidth = 0,
		TextTransparency = 0,
		TextWrapped = true,
		TextXAlignment = "Left",
		TextYAlignment = "Top",
		UIClickable = true,
		ZIndex = 32001,
	}, Field8)
end
plugin:Operator({
	Id = "instance.serialize",
	Label = "Export",
	Params = {
		{ Name = "output", Type = "string", Default = "ui" },
		{ Name = "targets", Type = "instances", From = "Selection" },
	},
	Icon = "Assets/Icons/bruh.svg",
	Poll = function(ctx: PluginContext)
    if #ctx.Selection == 0 then
        return false, "Select at least 1 instance to export it!"
    end
    return true
	end,
	Execute = function(ctx, params)
		params.output = params.output:lower()

		if params.output and not table.find({ "console", "ui" }, params.output) then
			return false, `[Instance.Serialize]: Only "console" and "ui" are acceptable output types!`
		end

		local output = {}
		for _, target: Instance in params.targets do
			local descendants = target:GetDescendants()
			table.insert(descendants, 1, target)

			for i, descendant in descendants do
				local components = {}
				local constructors = {}

				for _, name in descendant:GetComponents() do
					local ok, view: Component | string = pcall(function()
						return descendant:Component(name)
					end)

					if not ok and not view:find("has no fields") then
						warn(`[Instance.Serialize]: Unable to serialize component "{name}": {view or "¯\\_(ツ)_/¯"}`)
						continue
					end

					if typeof(view) == "string" then -- component tags are components with their name as a field
						local tagName = normalizeField(name, name)
						if not tagName then
							continue
						end

						local tagValue = propertyDB.presenceProperties[tagName]

						if tagName == nil or tagValue == nil then
							warn(
								`[Instance.Serialize]: Unable to serialize tag component "{name}": Unable to find map property {tagName} to a value`
							)
						else
							components[tagName] = tagValue
						end

						continue
					end

					for field, value in view do
						field = normalizeField(name, field)
						if not field then
							continue
						end

						local valueType = typeof(value)
						local constructor

						if valueType == "Vector3" then -- this tripped me up for so long...
							constructor = `Vector3.new({value.x}, {value.y}, {value.z})`
						elseif valueType == "UDim" then
							constructor = `UDim.new({value.Scale}, {value.Offset})`
						elseif valueType == "UDim2" then
							constructor =
								`UDim2.new({value.X.Scale}, {value.X.Offset}, {value.Y.Scale}, {value.Y.Offset})`
						elseif valueType == "NumberRange" then
							constructor = `NumberRange.new({value.Min}, {value.Max})`
						elseif valueType == "Rect" then
							constructor = `Rect.new({value.Min.x}, {value.Min.y}, {value.Max.x}, {value.Max.y})`
						end

						constructors[field] = constructor
						components[field] = if constructor then "__constructor__" else value
					end
				end

				if not next(components) then
					return false,
						`[Instance.Serialize]: Unable to serialize components of "{descendant.Name .. i}": There are none`
				end

				local ok: boolean, source: string =
					pcall(printify.block, components, { comment = false, sortkeys = true })
				if not ok then
					return false,
						`[Instance.Serialize]: Unable to serialize components of "{descendant.Name .. i}": {source}`
				end

				source = source:gsub('(\n +([%a_][%w_]*) = )"__constructor__"', function(prefix, field)
					local constructor = constructors[field]
					return constructor and prefix .. constructor
				end)

				local parent = normalizeName(descendant.Parent, descendants)
				table.insert(
					output,
					`local {normalizeName(descendant, descendants)} = ctx.Edit:Create({"\n"}"Folder", {"\n"}{source} {(if parent
						then ",\n" .. parent
						else "")})`
				)
			end
		end

		if params.output == "console" then
			print(table.concat(output, "\n\n"))
		elseif params.output == "ui" then
			spawnOutputUi(ctx, table.concat(output, "\n\n"))
		end
		return true
	end,
})
plugin:Ribbon({ Group = "Instance Serializer", Items = { "instance.serialize" } })
