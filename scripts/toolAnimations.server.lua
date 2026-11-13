-- Adapted from WildPaintBrush's code that does the same thing but
-- specialized only for the right hand. This animates regardless of
-- where... for better or worse

-- Add this as an attachment to the tool and it should work
local BODY_PARTS = {
    "RightArm",
    "LeftArm",
    "Head",
    "Torso",
    "RightLeg",
    "LeftLeg",
}
local bodyPart = BODY_PARTS[self.Tool.gripHand] -- move this inside the functions if the tool placement gets updated dynamically

self.Equipped:Connect(function()
    local character = self:FindAncestorWithComponent("Character")
    if not character or character.PoseOffset[bodyPart].X == 90 then return end

    character.AnimLayers[7] = {
        clip = "idle",
        speed = 0,
        mask = game.Animation.Part[bodyPart],
        loop = true,
        weight = 1
    }

    local equipTween = game.Tween.TweenProperty(character.PoseOffset, bodyPart, Vector3.new(90, 0, 0), 1)
    equipTween:Play()

    equipTween.Finished:Connect(function()
        character.AnimLayers[7] = nil
    end)
end)

self.Unequipped:Connect(function()
    local character = self:FindAncestorWithComponent("Character")
    if not character or character.PoseOffset[bodyPart].X == 0 then return end

    character.AnimLayers[7] = nil

    local equipTween = game.Tween.TweenProperty(character.PoseOffset, bodyPart, Vector3.new(0, 0, 0), 1)
    equipTween:Play()
end)
