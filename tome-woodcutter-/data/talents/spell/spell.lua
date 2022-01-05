-- From arcanum class pack
damDesc = function(self, type, dam)
	-- Increases damage
	if self.inc_damage then
		local inc = (self.inc_damage.all or 0) + (self.inc_damage[type] or 0)
		dam = dam + (dam * inc / 100)
	end
	return dam
end

-- Generic requires for spells based on talent level
spells_req_high1 = {
	stat = { mag=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
spells_req_high2 = {
	stat = { mag=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
spells_req_high3 = {
	stat = { mag=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
spells_req_high4 = {
	stat = { mag=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}

if not Talents.talents_types_def["spell/haunted-woods"] then
	newTalentType{ allow_random=true, type="spell/haunted-woods", no_silence=true, is_spell=true, min_lev = 10, name = "haunted-woods", description = "You are familiar with those creepy sounds in the forest night. Both the harmless ones, and the ones you should be scared about." }
  load("/data-woodcutter/talents/spell/haunted-woods.lua")
end