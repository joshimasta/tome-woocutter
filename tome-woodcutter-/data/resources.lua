
local ActorResource = require "engine.interface.ActorResource"
local ActorTalents = require "engine.interface.ActorTalents"


ActorResource:defineResource(_t"Firewood", "firewood", ActorTalents.T_FIREWOOD_POOL, "firewood_regen", _t"This is the amount of firewood you are carrying.", nil, nil, {
	color = "#bebebe#",
	randomboss_enhanced = true,
	wait_on_rest = true,
	Minimalist = {shader_params = {color = {0x90/255, 0x40/255, 0x10/255}}} --parameters for the Minimalist uiset
})

