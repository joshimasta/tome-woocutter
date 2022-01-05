
-- From arcanum class pack
damDesc = function(self, type, dam)
	-- Increases damage
	if self.inc_damage then
		local inc = (self.inc_damage.all or 0) + (self.inc_damage[type] or 0)
		dam = dam + (dam * inc / 100)
	end
	return dam
end

-- Generic requires for techs based on talent level
-- Uses STR
techs_req1 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
} end
techs_req2 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
} end
techs_req3 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
} end
techs_req4 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
} end
techs_req5 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
} end

-- Generic requires for techs_con based on talent level
techs_con_req1 = {
	stat = { con=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
techs_con_req2 = {
	stat = { con=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
techs_con_req3 = {
	stat = { con=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
techs_con_req4 = {
	stat = { con=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
techs_con_req5 = {
	stat = { con=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

if not Talents.talents_types_def["technique/woodcutter"] then
	newTalentType{ allow_random=false, type="technique/woodcutter", name = "woodcutter", description = "Generic woodcutting talents." }
  load("/data-woodcutter/talents/techniques/woodcutter.lua")
end
if not Talents.talents_types_def["technique/firewood"] then
	newTalentType{ allow_random=false, type="technique/firewood", name = "firewood", description = "Talents related to firewood and their uses." }
  load("/data-woodcutter/talents/techniques/firewood.lua")
end
if not Talents.talents_types_def["technique/axes"] then
	newTalentType{ allow_random=true, type="technique/axes", name = "axes", description = "Generic axe talents." }
  load("/data-woodcutter/talents/techniques/axes.lua")
end
if not Talents.talents_types_def["technique/herblore"] then
	newTalentType{ allow_random=true, generic=true, type="technique/herblore", name = "herblore", description = "Mastery of use of herbs and other plants." }
  load("/data-woodcutter/talents/techniques/herblore.lua")
end