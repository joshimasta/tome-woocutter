
newTalent{
	name = "Firewood Pool",
	type = {"base/class", 1},
	info = "Allows you to have a firewood pool.",
	mode = "passive",
	no_unlearn_last = true,
}

lev_req1 = {
	level = function(level) return 0 + (level-1)  end,
}
lev_req2 = {
	level = function(level) return 4 + (level-1)  end,
}
lev_req3 = {
	level = function(level) return 8 + (level-1)  end,
}
lev_req4 = {
	level = function(level) return 12 + (level-1)  end,
}
lev_req5 = {
	level = function(level) return 16 + (level-1)  end,
}

if not Talents.talents_types_def["commoner/commoner-in-combat"] then
	newTalentType{ allow_random=true, type="commoner/commoner-in-combat", name = "commoner-in-combat", description = "You take advantage of your background in the civil world." }
  load("/data-woodcutter/talents/misc/commoner.lua")
end