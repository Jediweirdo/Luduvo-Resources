# Jedi's Luduvo Resources
Luduvo stuff that others might find neat

Since this is a personal project, all pretenses of trying in this readme have been thrown out the window

## Plugins

### Character Spawner

It spawns user avatars for you to use in your game after like 2 minutes prep time. Requires you to go fetch the data yourself though from https://luduvo-manifest.jediweirdo.workers.dev/ unless you don't want accessories to work.

I really should not have needed 2 plugins and a website to make this, but that's how the cookie crumbles. TL;DR version of the code in TutorialCode, Library-ready code in the runtime folder, and make sure one of those two things makes its way to your autorun folder alongside an export of your registered characters. I will add a better way to store characters between sessions later.

If you want better instructions, play the tutorial command. It'll give you everything you need.

### Instance Serializer

Plugins aren't allowed to make prefabs. ctx.Edit sucks. Grass is green. So this is my workaround for it in case anyone might need the tech that I did to make complex and intricate plugins such as character spawner. Note that that plugin in particular is an almalgamation of my code and an AI agent that generated a switch case to handle every single component in Luduvo history.

It works ok, but ctx.Edit still sucks so there's a lot of components that are not exportable due to random middle fingers indube to you by the big man himself. The process of making this has really reminded me how messy components can be in Luduvo.

## Shaders

### Rainbow Outliner

This shader outlines objects with a rainbow color gradient that can be rotated via some looping luau code and parameter editing. It also comes with an auto-applier that's supposed to apply the shader to all tagged objects in the scene automatically but it doesn't work well. Be sure to replace that `MATERIAL_ID_OFFSET` with the actual latest material ID in your game. You can do that by making a new material, copying its offset, and then deleting it (if you couldn't tell the code is hacky as heck)

### Mirror

It's a Mirror! But useless! Because it only reflects the skybox! I make it in 30 mintues! Because I didn't know what I was doing! I still don't know what I'm doing! Why am I ending every sentence with an exclamation mark?! I don't know!
