local json = require("./json")
local spawn = require("./characterSpawner")
local printify = require("./printify")
local presets = require("./runtime/CharacterDressPresets")
local tutorialCode = require("./tutorialCode")
local aliases = {}

local numberFields = { user_id = true, item_id = true, rules = true }

local function decodeManifest(source)
	-- Studio has been screwing with me and stripping literally every quotation
	-- mark out of the json output  so now I'm stuck adding them all back
	-- And as in "me", I mean AI. This function was more or less AI generated
	-- For ledigibility, I also asked it to leave a comment denoting what each regex
	-- string did

	local ok, result = pcall(json.deserialize, source)
	if ok then
		return result
	end
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
			if not token:match("^[%a_][%w_]*$") then
				error(result, 0)
			end
			field = token
			table.insert(tokens, json.serialize(token))
		else
			if token ~= "" then
				-- Reject backslashes because the original string escapes are ambiguous.
				if not field or token:find("\\", 1, true) then
					error(result, 0)
				end
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

local function spawnCharacter(ctx)
	local Character1 = ctx.Edit:Create("Folder", {
		AngularDamping = 0.5,
		AutoLocomotion = true,
		AutoRotate = true,
		BodyColorHead = Vector3.new(0, 0, 0),
		BodyColorLeftArm = Vector3.new(0, 0, 0),
		BodyColorLeftLeg = Vector3.new(0, 0, 0),
		BodyColorRightArm = Vector3.new(0, 0, 0),
		BodyColorRightLeg = Vector3.new(0, 0, 0),
		BodyColorTorso = Vector3.new(0, 0, 0),
		BodyHead = "165",
		BodyLeftArm = "165",
		BodyLeftLeg = "165",
		BodyRightArm = "165",
		BodyRightLeg = "165",
		BodyTorso = "165",
		CharacterAnimation = true,
		CharacterPhysics = true,
		CharacterRig = true,
		CollisionGroup = "Character",
		Density = 3.5,
		Face = "0",
		FreezePosition = 0,
		FreezeRotation = 0,
		Friction = 0.30000001192092896,
		GravityScale = 1,
		Health = 100,
		HipHeight = 2,
		JumpPower = 50,
		LinearDamping = 0.30000001192092896,
		MaxHealth = 100,
		MaxSlopeAngle = 89,
		Name = "Character",
		Orientation = Vector3.new(-0, 0, 0),
		Pants = "0",
		Part = "Torso",
		Position = Vector3.new(0, 3, 0),
		Restitution = 0,
		Shirt = "0",
		Size = Vector3.new(2, 2, 1),
		Type = "Box",
		Velocity = Vector3.new(0, 0, 0),
		WalkSpeed = 16,
	})

	local Head2 = ctx.Edit:Create("Folder", {
		Anchor = Vector3.new(0, 1, 0),
		AngularDamping = 0.5,
		CollisionGroup = "Character",
		Density = 1,
		FreezePosition = 0,
		FreezeRotation = 0,
		Friction = 0.30000001192092896,
		FrictionTorque = 0,
		GravityScale = 1,
		LinearDamping = 0.30000001192092896,
		Name = "Head",
		NormalCone = 20,
		Orientation = Vector3.new(-0, 0, 0),
		Part = "Head",
		PlaneAxis = Vector3.new(1, 0, 0),
		PlaneCone = 20,
		Position = Vector3.new(0, 4.5, 0),
		Restitution = 0,
		Size = Vector3.new(2, 1, 1),
		TwistAxis = Vector3.new(0, 1, 0),
		TwistMax = 90,
		TwistMin = -90,
		Type = "Box",
	}, Character1)

	local Left_Arm3 = ctx.Edit:Create("Folder", {
		Anchor = Vector3.new(-1.2999999523162842, 0.75, 0),
		AngularDamping = 0.5,
		CollisionGroup = "Character",
		Density = 1,
		FreezePosition = 0,
		FreezeRotation = 0,
		Friction = 0.30000001192092896,
		FrictionTorque = 0,
		GravityScale = 1,
		LinearDamping = 0.30000001192092896,
		Name = "Left Arm",
		NormalCone = 90,
		Orientation = Vector3.new(-0, 0, 0),
		Part = "LeftArm",
		PlaneAxis = Vector3.new(-0.7933499813079834, 0.6087599992752075, 0),
		PlaneCone = 52.5,
		Position = Vector3.new(-1.5, 3, 0),
		Restitution = 0,
		Size = Vector3.new(1, 2, 1),
		TwistAxis = Vector3.new(-0.6087599992752075, -0.7933499813079834, 0),
		TwistMax = 45,
		TwistMin = -45,
		Type = "Box",
	}, Character1)

	local Right_Arm4 = ctx.Edit:Create("Folder", {
		Anchor = Vector3.new(1.2999999523162842, 0.75, 0),
		AngularDamping = 0.5,
		CollisionGroup = "Character",
		Density = 1,
		FreezePosition = 0,
		FreezeRotation = 0,
		Friction = 0.30000001192092896,
		FrictionTorque = 0,
		GravityScale = 1,
		LinearDamping = 0.30000001192092896,
		Name = "Right Arm",
		NormalCone = 90,
		Orientation = Vector3.new(-0, 0, 0),
		Part = "RightArm",
		PlaneAxis = Vector3.new(0.7933499813079834, 0.6087599992752075, 0),
		PlaneCone = 52.5,
		Position = Vector3.new(1.5, 3, 0),
		Restitution = 0,
		Size = Vector3.new(1, 2, 1),
		TwistAxis = Vector3.new(0.6087599992752075, -0.7933499813079834, 0),
		TwistMax = 45,
		TwistMin = -45,
		Type = "Box",
	}, Character1)

	local Left_Leg5 = ctx.Edit:Create("Folder", {
		Anchor = Vector3.new(-0.5, -1, 0),
		AngularDamping = 0.5,
		CollisionGroup = "Character",
		Density = 1,
		FreezePosition = 0,
		FreezeRotation = 0,
		Friction = 0.30000001192092896,
		FrictionTorque = 0,
		GravityScale = 1,
		LinearDamping = 0.30000001192092896,
		Name = "Left Leg",
		NormalCone = 20,
		Orientation = Vector3.new(-0, 0, 0),
		Part = "LeftLeg",
		PlaneAxis = Vector3.new(0, 0.3826799988746643, -0.9238799810409546),
		PlaneCone = 67.5,
		Position = Vector3.new(-0.5, 1, 0),
		Restitution = 0,
		Size = Vector3.new(1, 2, 1),
		TwistAxis = Vector3.new(0, -0.9238799810409546, -0.3826799988746643),
		TwistMax = 10,
		TwistMin = -10,
		Type = "Box",
	}, Character1)

	local Right_Leg6 = ctx.Edit:Create("Folder", {
		Anchor = Vector3.new(0.5, -1, 0),
		AngularDamping = 0.5,
		CollisionGroup = "Character",
		Density = 1,
		FreezePosition = 0,
		FreezeRotation = 0,
		Friction = 0.30000001192092896,
		FrictionTorque = 0,
		GravityScale = 1,
		LinearDamping = 0.30000001192092896,
		Name = "Right Leg",
		NormalCone = 20,
		Orientation = Vector3.new(-0, 0, 0),
		Part = "RightLeg",
		PlaneAxis = Vector3.new(0, 0.3826799988746643, -0.9238799810409546),
		PlaneCone = 67.5,
		Position = Vector3.new(0.5, 1, 0),
		Restitution = 0,
		Size = Vector3.new(1, 2, 1),
		TwistAxis = Vector3.new(0, -0.9238799810409546, -0.3826799988746643),
		TwistMax = 10,
		TwistMin = -10,
		Type = "Box",
	}, Character1)

	local BackAttachment7 = ctx.Edit:Create("Folder", {
		IsRoot = false,
		Name = "BackAttachment",
		Orientation = Vector3.new(-0, 0, 0),
		Position = Vector3.new(0, 3, 0.5),
		Slot = "Back",
	}, Character1)

	local LeftShoulderAttachment8 = ctx.Edit:Create("Folder", {
		IsRoot = false,
		Name = "LeftShoulderAttachment",
		Orientation = Vector3.new(-0, 0, 0),
		Position = Vector3.new(-1, 4, 0),
		Slot = "LeftShoulder",
	}, Character1)

	local RightShoulderAttachment9 = ctx.Edit:Create("Folder", {
		IsRoot = false,
		Name = "RightShoulderAttachment",
		Orientation = Vector3.new(-0, 0, 0),
		Position = Vector3.new(1, 4, 0),
		Slot = "RightShoulder",
	}, Character1)

	local WaistAttachment10 = ctx.Edit:Create("Folder", {
		IsRoot = false,
		Name = "WaistAttachment",
		Orientation = Vector3.new(-0, 0, 0),
		Position = Vector3.new(0, 2, 0),
		Slot = "Waist",
	}, Character1)

	local FrontAttachment11 = ctx.Edit:Create("Folder", {
		IsRoot = false,
		Name = "FrontAttachment",
		Orientation = Vector3.new(-0, 0, 0),
		Position = Vector3.new(0, 3, -0.5),
		Slot = "Front",
	}, Character1)

	local NeckAttachment12 = ctx.Edit:Create("Folder", {
		IsRoot = false,
		Name = "NeckAttachment",
		Orientation = Vector3.new(-0, 0, 0),
		Position = Vector3.new(0, 4, 0),
		Slot = "Neck",
	}, Character1)

	local HatAttachment13 = ctx.Edit:Create("Folder", {
		IsRoot = false,
		Name = "HatAttachment",
		Orientation = Vector3.new(-0, 0, 0),
		Position = Vector3.new(0, 5.099999904632568, 0),
		Slot = "Hat",
	}, Head2)

	local HairAttachment14 = ctx.Edit:Create("Folder", {
		IsRoot = false,
		Name = "HairAttachment",
		Orientation = Vector3.new(-0, 0, 0),
		Position = Vector3.new(0, 5.099999904632568, 0),
		Slot = "Hair",
	}, Head2)

	local FaceAttachment15 = ctx.Edit:Create("Folder", {
		IsRoot = false,
		Name = "FaceAttachment",
		Orientation = Vector3.new(-0, 0, 0),
		Position = Vector3.new(0, 4.5, -0.6000000238418579),
		Slot = "Face",
	}, Head2)

	local face16 = ctx.Edit:Create("Folder", {
		Layer = 0,
		Name = "face",
		Side = "Front",
		Texture = "0",
	}, Head2)
	return Character1
end

local function spawnTutorial(ctx, alias)
	local aliasText = if alias then tostring(alias) else "the alias you registered"
	local Tutorial1 = ctx.Edit:Create("Folder", {
		AnchorPoint = Vector3.new(0, 0, 0),
		AspectRatio = 0,
		LayoutOrder = 0,
		MaxSize = UDim2.new(0, 0, 0, 0),
		MinSize = Vector3.new(0, 0, 0),
		Name = "Tutorial",
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		SizeModeX = "Fixed",
		SizeModeY = "Fixed",
		UIRoot = true,
		ZIndex = 32003,
	})

	local Dimmer2 = ctx.Edit:Create("Folder", {
		AnchorPoint = Vector3.new(0, 0, 0),
		AspectRatio = 0,
		BackgroundColor3 = Vector3.new(0.039000000804662704, 0.03999999910593033, 0.04100000113248825),
		BackgroundTransparency = 0.44999998807907104,
		LayoutOrder = 0,
		MaxSize = UDim2.new(0, 0, 0, 0),
		MinSize = Vector3.new(0, 0, 0),
		Name = "Dimmer",
		Position = UDim2.new(0, 0, 0, 0),
		Selectable = false,
		Size = UDim2.new(1, 0, 1, 0),
		SizeModeX = "Fixed",
		SizeModeY = "Fixed",
		UIClickable = true,
		ZIndex = 32001,
	}, Tutorial1)

	local Box3 = ctx.Edit:Create("Folder", {
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
		MaxSize = UDim2.new(1, -83, 1, -32),
		MinSize = Vector3.new(0, 0, 0),
		Name = "Box",
		Position = UDim2.new(0.5, 2, 0.5, 0),
		Selectable = false,
		SelectionGroup = true,
		Size = UDim2.new(0.734000027179718, 0, 0, 446.78515625),
		SizeModeX = "Fixed",
		SizeModeY = "Fit",
		Spacing = 16,
		UIClickable = true,
		ZIndex = 32000,
	}, Dimmer2)

	local Step_14 = ctx.Edit:Create("Folder", {
		AnchorPoint = Vector3.new(0, 0, 0),
		AspectRatio = 0,
		FontFamily = "Arimo",
		FontWeight = 400,
		Italic = false,
		LayoutOrder = 4,
		MaxSize = UDim2.new(0, 0, 0, 0),
		MinSize = Vector3.new(0, 0, 0),
		Name = "Step 1",
		NoTranslate = false,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 24),
		SizeModeX = "Fixed",
		SizeModeY = "Fit",
		Text = `First, go to your character(s) and add a "{presets.Tag}" tag and a string "{presets.AliasAttribute}" attribute set to {aliasText}. If the rig root is missing the Character component, add that too. I would have done this mysef, but y'know, limitations.`,
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
	}, Box3)

	local Crashout5 = ctx.Edit:Create("Folder", {
		AnchorPoint = Vector3.new(0, 0, 0),
		AspectRatio = 0,
		FontFamily = "Arimo",
		FontWeight = 400,
		Italic = false,
		LayoutOrder = 1,
		MaxSize = UDim2.new(0, 0, 0, 0),
		MinSize = Vector3.new(0, 0, 0),
		Name = "Crashout",
		NoTranslate = false,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 24),
		SizeModeX = "Fixed",
		SizeModeY = "Fit",
		Text = "You may have notice that your character is half-furnished and missing all its accessories. This is because plugins aren't allowed to query Luduvo for anything! That pesky Igor and his 'safety concerns' from letting plugins have unfettered access to the internet. So instead, the rest of your character furnishing has to happen at runtime.",
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
	}, Box3)

	local Here_s_How6 = ctx.Edit:Create("Folder", {
		AnchorPoint = Vector3.new(0, 0, 0),
		AspectRatio = 0,
		FontFamily = "Arimo",
		FontWeight = 400,
		Italic = false,
		LayoutOrder = 3,
		MaxSize = UDim2.new(0, 0, 0, 0),
		MinSize = Vector3.new(0, 0, 0),
		Name = "Here's How",
		NoTranslate = false,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 24),
		SizeModeX = "Fixed",
		SizeModeY = "Fit",
		Text = "Here's how:",
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
	}, Box3)

	local Title7 = ctx.Edit:Create("Folder", {
		AnchorPoint = Vector3.new(0, 0, 0),
		AspectRatio = 0,
		FontFamily = "Arimo",
		FontWeight = 700,
		Italic = false,
		LayoutOrder = -1,
		MaxSize = UDim2.new(0, 0, 0, 0),
		MinSize = Vector3.new(0, 0, 0),
		Name = "Title",
		NoTranslate = false,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 28),
		SizeModeX = "Fixed",
		SizeModeY = "Fit",
		Text = "Setting Up",
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
	}, Box3)

	local Code_Output8 = ctx.Edit:Create("Folder", {
		Align = "Center",
		AnchorPoint = Vector3.new(0, 0, 0),
		AspectRatio = 0,
		Axis = "Vertical",
		BackgroundColor3 = Vector3.new(0.943, 0.948, 0.957),
		BackgroundTransparency = 0.94,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ClipsDescendants = true,
		CornerRadius = 4,
		Justify = "Start",
		LayoutOrder = 6,
		MarginBottom = 12,
		MarginLeft = 12,
		MarginRight = 12,
		MarginTop = 12,
		MaxSize = UDim2.new(0, 0, 0, 0),
		MinSize = Vector3.new(0, 0, 0),
		Name = "Code Output",
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 138),
		SizeModeX = "Fixed",
		SizeModeY = "Fixed",
		Spacing = 12,
		ZIndex = 32000,
	}, Box3)

	ctx.Edit:Create("Folder", {
		Name = "code",
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 0),
		SizeModeX = "Fixed",
		SizeModeY = "Fit",
		Text = tutorialCode,
		TextColor3 = Vector3.new(0.943, 0.948, 0.957),
		TextSize = 16,
		TextWrapped = true,
		TextXAlignment = "Left",
		TextYAlignment = "Top",
		NoTranslate = true,
		PlaceholderText = "",
		MaxLength = 0,
		Cursor = "Text",
		UIClickable = true,
		ZIndex = 32001,
	}, Code_Output8)

	local Step_39 = ctx.Edit:Create("Folder", {
		AnchorPoint = Vector3.new(0, 0, 0),
		AspectRatio = 0,
		FontFamily = "Arimo",
		FontWeight = 400,
		Italic = false,
		LayoutOrder = 5,
		MaxSize = UDim2.new(0, 0, 0, 0),
		MinSize = Vector3.new(0, 0, 0),
		Name = "Step 3",
		NoTranslate = false,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 24),
		SizeModeX = "Fixed",
		SizeModeY = "Fit",
		Text = [[After that, open your assets tab and open your "scripts" folder. Make an "autorun" folder if you don't already have one. Inside it, make a file called "CharacterDress.server.lua" and paste in the code below.]],
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
	}, Box3)

	local Step_410 = ctx.Edit:Create("Folder", {
		AnchorPoint = Vector3.new(0, 0, 0),
		AspectRatio = 0,
		FontFamily = "Arimo",
		FontWeight = 400,
		Italic = false,
		LayoutOrder = 8,
		MaxSize = UDim2.new(0, 0, 0, 0),
		MinSize = Vector3.new(0, 0, 0),
		Name = "Step 4",
		NoTranslate = false,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 24),
		SizeModeX = "Fixed",
		SizeModeY = "Fit",
		Text = "And after that, you're good! Next time you run your game, you should see that your character's appearance loads all the way in.",
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
	}, Box3)

	local Close_Notice12 = ctx.Edit:Create("Folder", {
		AnchorPoint = Vector3.new(0, 0, 0),
		AspectRatio = 0,
		FontFamily = "Arimo",
		FontWeight = 400,
		Italic = false,
		LayoutOrder = 10,
		MaxSize = UDim2.new(0, 0, 0, 0),
		MinSize = Vector3.new(0, 0, 0),
		Name = "Close Notice",
		NoTranslate = false,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 24),
		SizeModeX = "Fixed",
		SizeModeY = "Fit",
		Text = "If you understand, good. You can delete these instructions now",
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
	}, Box3)

	local ScrollingFrame_Notice13 = ctx.Edit:Create("Folder", {
		AnchorPoint = Vector3.new(0, 0, 0),
		AspectRatio = 0,
		FontFamily = "Arimo",
		FontWeight = 400,
		Italic = false,
		LayoutOrder = 0,
		MaxSize = UDim2.new(0, 0, 0, 0),
		MinSize = Vector3.new(0, 0, 0),
		Name = "ScrollingFrame Notice",
		NoTranslate = false,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 24),
		SizeModeX = "Fixed",
		SizeModeY = "Fit",
		Text = 'If this is clipping offscreen, press the "run" button. This is a scroling textbox so you should be able to read it',
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
	}, Box3)

	local Step_214 = ctx.Edit:Create("Folder", {
		AnchorPoint = Vector3.new(0, 0, 0),
		AspectRatio = 0,
		FontFamily = "Arimo",
		FontWeight = 400,
		Italic = false,
		LayoutOrder = 4,
		MaxSize = UDim2.new(0, 0, 0, 0),
		MinSize = Vector3.new(0, 0, 0),
		Name = "Step 2",
		NoTranslate = false,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 24),
		SizeModeX = "Fixed",
		SizeModeY = "Fit",
		Text = 'Next, press the "Export" plugin and follow the instructions there to properly export your registered characters',
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
	}, Box3)

	local Step_3_515 = ctx.Edit:Create("Folder", {
		AnchorPoint = Vector3.new(0, 0, 0),
		AspectRatio = 0,
		FontFamily = "Arimo",
		FontWeight = 400,
		Italic = false,
		LayoutOrder = 7,
		MaxSize = UDim2.new(0, 0, 0, 0),
		MinSize = Vector3.new(0, 0, 0),
		Name = "Step 3.5",
		NoTranslate = false,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 24),
		SizeModeX = "Fixed",
		SizeModeY = "Fit",
		Text = 'Save the exported registry as "scripts/CharacterData.lua" (case sensitive). The autorun script above loads it from there.',
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
	}, Box3)
end

local function spawnExport(ctx, code)
	local Exporter1 = ctx.Edit:Create("Folder", {
		AnchorPoint = Vector3.new(0, 0, 0),
		AspectRatio = 0,
		LayoutOrder = 0,
		MaxSize = UDim2.new(0, 0, 0, 0),
		MinSize = Vector3.new(0, 0, 0),
		Name = "Exporter",
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
		Size = UDim2.new(0.5, 400, 0, 325.990234375),
		SizeModeX = "Fixed",
		SizeModeY = "Fit",
		Spacing = 16,
		UIClickable = true,
		ZIndex = 32000,
	}, Exporter1)

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
		Text = "Copy the text below and save it as scripts/CharacterData.lua.",
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

	local Code_Output5 = ctx.Edit:Create("Folder", {
		Align = "Center",
		AnchorPoint = Vector3.new(0, 0, 0),
		AspectRatio = 0,
		Axis = "Horizontal",
		Justify = "Start",
		LayoutOrder = 3,
		MarginBottom = 0,
		MarginLeft = 0,
		MarginRight = 0,
		MarginTop = 0,
		MaxSize = UDim2.new(0, 0, 0, 0),
		MinSize = Vector3.new(0, 0, 0),
		Name = "Code Output",
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 138),
		SizeModeX = "Fixed",
		SizeModeY = "Fixed",
		Spacing = 12,
		ZIndex = 32000,
	}, Box2)

	local Stale_Notice6 = ctx.Edit:Create("Folder", {
		AnchorPoint = Vector3.new(0, 0, 0),
		AspectRatio = 0,
		FontFamily = "Arimo",
		FontWeight = 400,
		Italic = false,
		LayoutOrder = 4,
		MaxSize = UDim2.new(0, 0, 0, 0),
		MinSize = Vector3.new(0, 0, 0),
		Name = "Stale Notice",
		NoTranslate = false,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 24),
		SizeModeX = "Fixed",
		SizeModeY = "Fit",
		Text = "Be sure to re-export whenever you register a new character! Ok, you can delete this whenever you're done",
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

	local Field7 = ctx.Edit:Create("Folder", {
		Align = "Center",
		AnchorPoint = Vector3.new(0, 0, 0),
		AspectRatio = 0,
		Axis = "Vertical",
		BackgroundColor3 = Vector3.new(0.9430000185966492, 0.9480000138282776, 0.9570000171661377),
		BackgroundTransparency = 0.94000000134110451,
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
	}, Code_Output5)

	local code8 = ctx.Edit:Create("Folder", {
		AnchorPoint = Vector3.new(0, 0, 0),
		AspectRatio = 0,
		Cursor = "Text",
		FontFamily = "Arimo",
		FontWeight = 400,
		Italic = false,
		LayoutOrder = 0,
		MaxLength = 0,
		MaxSize = UDim2.new(0, 0, 0, 0),
		MinSize = Vector3.new(0, 0, 0),
		Name = "code",
		NoTranslate = true,
		PlaceholderText = "",
		Position = UDim2.new(0, 0, 0, 40),
		Size = UDim2.new(1, 0, 0, 552),
		SizeModeX = "Fixed",
		SizeModeY = "Fixed",
		Text = code,
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
	}, Field7)
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
		if not ok then
			return false, `[Character.Register.Json]: Failed to deserialize JSON: {manifest}`
		end
		if not json.asObject(manifest) or type(manifest.user_id) ~= "number" then
			return false, "[Character.Register.Json]: Expected a numeric user_id"
		end

		local alias = if params.alias and params.alias ~= "" then params.alias else tostring(manifest.user_id)
		if aliases[alias] then
			return false, `[Character.Register.Json]: "{alias}" has already been registered`
		end

		local record, reason = spawn.fromAPI(manifest)
		if not record then
			return false, `[Character.Register.Json]: {reason}`
		end
		aliases[alias] = record

		print("[Character.Register.Json] Successfully Registered Alias " .. alias)
		return true
	end,
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
			Name = "tutorial",
			Type = "boolean",
			Default = false,
		},
	},
	Icon = "Assets/Icons/stickFigure.svg",
	Prefab = "Assets/Prefabs/Spawn.ldv",
	-- Poll = function(_)
	-- 	if next(aliases) == nil then
	-- 		return false, "Register a character before exporting"
	-- 	end

	-- 	return true
	-- end,
	Execute = function(ctx, params)
		local record = aliases[params.alias]
		if not record then
			return false,
				`[Character.Spawn]: "{params.alias}" hasn't been registered. Set it up with character.register.json first`
		end

		local targets = if #ctx.Selection == 0 then { spawnCharacter(ctx) } else ctx.Selection

		for _, target: Instance in targets do
			-- The editor-built rig has CharacterRig and BodyPart without the Character tag.
			if
				not target:HasComponent("Character")
				and not (target:HasComponent("CharacterRig") and target:HasComponent("BodyPart"))
			then
				warn(`[Character.Spawn]: "{target.Name}" is not a character. Skipping.`)
				continue
			end

			spawn.Apply(ctx, record, target)
		end

		if #record.manifest.Accessories > 0 then
			warn("[Character.Spawn]: Studio plugins still cannot use Content.Fetch in edit mode.")
		end

		if params.tutorial then
			spawnTutorial(ctx, params.alias)
		end
		return true
	end,
})

plugin:Operator({
	Id = "character.export",
	Label = "Export",
	Params = {
		{ Name = "output", Type = "string", Default = "ui", Hidden = true },
	},
	-- Poll = function(_)
	-- 	if next(aliases) == nil then
	-- 		return false, "Register a character before exporting"
	-- 	end

	-- 	return true
	-- end,
	Icon = "Assets/Icons/bruh.svg",
	Execute = function(ctx, params)
		local output = string.lower(params.output or "ui")

		if output ~= "console" and output ~= "ui" then
			return false, `[Character.Export]: Only "console" and "ui" are acceptable output types!`
		end

		if next(aliases) == nil then
			return false, "[Character.Export]: There is nothing to export! Register a character before exporting"
		end
		local source, reason = printify(aliases)

		if not source then
			return false, reason
		end

		if output == "console" then
			print(source)
		else
			spawnExport(ctx, source)
		end

		return true
	end,
})

plugin:Operator({
	Id = "character.tutorial",
	Label = "Tutorial",
	Icon = "Assets/Icons/bruh.svg",
	Execute = function(ctx)
		spawnTutorial(ctx)
		return true
	end,
})

plugin:Ribbon({
	Group = "Character",
	Items = { "character.register.json", "character.spawn", "character.export", "character.tutorial" },
})
