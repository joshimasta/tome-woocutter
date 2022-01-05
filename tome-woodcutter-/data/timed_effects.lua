local Particles = require "engine.Particles"

newEffect{
	name = "WOODCUTTER_PHYSICAL_SURGE", image = "effects/woodcutter_physical_surge.png",
	desc = _t"Physical Surge",
	long_desc = function(self, eff) return ("The target's physical power has been increased by %d."):tformat(eff.cur_power or eff.power) end,
	charges = function(self, eff) return math.floor(eff.cur_power or eff.power) end,
	type = "physical",
	subtype = { physical=true },
	status = "beneficial",
	parameters = { power=10 },
	--on_gain = function(self, err) return _t"#Target# is surging arcane power.", _t"+Spellsurge" end,
	--on_lose = function(self, err) return _t"#Target# is no longer surging arcane power.", _t"-Spellsurge" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("combat_dam", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_dam", eff.tmpid)
	end,
}
newEffect{
	name = "WOODCUTTER_SOUNDS", image = "effects/woodcutter_physical_surge.png",
	-- functionality of this effect is implemented elsewhere, because this was supposed to be a sustain.
	desc = _t"One with the Sounds",
	long_desc = function(self, eff) return ("The target is one with sounds, dealing damage and terrifying nearby enemies."):tformat(eff.cur_power or eff.power) end,
	charges = function(self, eff) return math.floor(eff.cur_power or eff.power) end,
	type = "magical",
	subtype = { physical=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return _t"#Target# is one with the sounds.", _t"+One with the Sounds" end,
	on_lose = function(self, err) return _t"#Target# is no longer one with the sounds.", _t"-One with the Sounds" end,
	-- activate = function(self, eff)
	-- 	eff.tmpid = self:addTemporaryValue("combat_dam", eff.power)
	-- end,
	-- deactivate = function(self, eff)
	-- 	self:removeTemporaryValue("combat_dam", eff.tmpid)
	-- end,
}

newEffect{
	name = "WOODCUTTER_REGENERATION", image = "talents/woodcutter_healing_herbs.png",
	desc = _t"Regeneration",
	long_desc = function(self, eff) return ("A flow of life spins around the target, regenerating %0.2f life per turn."):tformat(eff.power) end,
	type = "physical",
	subtype = { nature=true, healing=true, regeneration=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return _t"#Target# starts regenerating health quickly.", _t"+Regen" end,
	on_lose = function(self, err) return _t"#Target# stops regenerating health quickly.", _t"-Regen" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("life_regen", eff.power)

		if core.shader.active(4) then
			eff.particle1 = self:addParticles(Particles.new("shader_shield", 1, {toback=true,  size_factor=1.5, y=-0.3, img="healarcane"}, {type="healing", time_factor=4000, noup=2.0, circleColor={0,0,0,0}, beamsCount=9}))
			eff.particle2 = self:addParticles(Particles.new("shader_shield", 1, {toback=false, size_factor=1.5, y=-0.3, img="healarcane"}, {type="healing", time_factor=4000, noup=1.0, circleColor={0,0,0,0}, beamsCount=9}))
		end

	end,
	on_timeout = function(self, eff)
		if self:knowTalent(self.T_ANCESTRAL_LIFE) then
			local t = self:getTalentFromId(self.T_ANCESTRAL_LIFE)
			self:incEquilibrium(-t.getEq(self, t))
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle1)
		self:removeParticles(eff.particle2)
		self:removeTemporaryValue("life_regen", eff.tmpid)
	end,
}

newEffect{
	name = "WOODCUTTER_POWER_REDUCED", image = "effects/intimidated.png",
	desc = _t"Power Reduced",
	long_desc = function(self, eff) return ("Target's offensive capabilities are reduced."):tformat(eff.power) end,
	charges = function(self, eff) return math.round(eff.power) end,
	type = "physical",
	subtype = { },
	status = "detrimental",
	on_gain = function(self, err) return _t"#Target#'s power has been lowered.", _t"+Power Reduced" end,
	on_lose = function(self, err) return _t"#Target# has regained its power.", _t"-Power Reduced" end,
	parameters = { power=1 },
	activate = function(self, eff)
		eff.damid = self:addTemporaryValue("combat_dam", -eff.power)
		eff.spellid = self:addTemporaryValue("combat_spellpower", -eff.power)
		eff.mindid = self:addTemporaryValue("combat_mindpower", -eff.power)
	end,
	deactivate = function(self, eff)
		if eff.particle then self:removeParticles(eff.particle) end
		self:removeTemporaryValue("combat_dam", eff.damid)
		self:removeTemporaryValue("combat_spellpower", eff.spellid)
		self:removeTemporaryValue("combat_mindpower", eff.mindid)
	end,
}
