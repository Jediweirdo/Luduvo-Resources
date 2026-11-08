local RAINBOW_DISPLACEMENT_PARAM = "colorDisplacement"
local RAINBOW_DISPLACEMENT_SPEED = 1
local RAINBOW_MATERIAL_TRACKER_PARENT = game.World

local rainbowTracker = RAINBOW_MATERIAL_TRACKER_PARENT:WaitForChild("RainbowTracker", 5)

local displacement = 0

function Update(dt) -- if you REALLY care about the rainbow rotating consistently, change this to PhysicsUpdate
    displacement = (displacement + dt * RAINBOW_DISPLACEMENT_SPEED) % 1

	for name, _ in rainbowTracker.attr do
		game.Materials.SetParam(name, RAINBOW_DISPLACEMENT_PARAM, displacement)
	end
end
