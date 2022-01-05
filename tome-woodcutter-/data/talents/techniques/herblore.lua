
newTalent{
	name = "Lightweight Leaves", short_name = "WOODCUTTER_LIGHTWEIGHT_LEAVES",
	type = {"technique/herblore", 1},
  image = "talents/woodcutter_lightweight_leaves.png",
	points = 5,
	require = techs_con_req1,
	mode = "passive",
  getSpeed = function(self, t) return self:combatTalentStatDamage(t, "con", 0.08, 0.45) end,
	getSave = function(self, t) return math.floor(self:combatTalentScale(t, 6, 28)) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_mentalresist", t.getSave(self, t))
		self:talentTemporaryValue(p, "movement_speed", t.getSpeed(self, t))
	end,
	info = function(self, t)
		return ([[Eating correct leaves allows your feet and your mind run lighter than normal. Increases movement speed by %d%% based on your constitution and increases mind save by %d.]]):
		tformat(100*t.getSpeed(self, t), t.getSave(self, t))
	end
}
newTalent{
  name = "Resistance Roots", short_name = "WOODCUTTER_RESISTANCE_ROOTS",
  image = "talents/woodcutter_resistance_roots.png",
  type = {"technique/herblore", 2},
  points = 5,
  require = techs_con_req2,
  mode = "passive",
  getResistance = function(self, t) return self:combatTalentScale(t, 0.1, 0.45, 0.5) end,
  getRegen = function(self, t) return self:combatTalentScale(t, 2, 10, 0.5) end,
  getThresholdMultiplier = function(self, t) return (self:combatTalentScale(t, 0.6, 1.6, 0.35) ) end,
  getThreshold = function(self, t) return self:getCon() * t.getThresholdMultiplier(self, t) end,
  getDamageMultiplier = function(self, t) return 0.65 end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "cut_immune", t.getResistance(self, t))
		self:talentTemporaryValue(p, "poison_immune", t.getResistance(self, t))
		self:talentTemporaryValue(p, "disease_immune", t.getResistance(self, t))
	end,
  info = function(self, t)
    return ([[Eating certain roots can make your body highly resistant. You gain %d%% poison, disease and wound resistance and whenever you take less than %d damage (%0.2f times your constitution), it is reduced by %d%%.]]):
    tformat(t.getResistance(self, t)*100, t.getThreshold(self, t), t.getThresholdMultiplier(self, t), 100*(1 - t.getDamageMultiplier(self, t)))
  end
}
newTalent{
  name = "Healing Herbs", short_name = "WOODCUTTER_HEALING_HERBS",
  image = "talents/woodcutter_healing_herbs.png",
  type = {"technique/herblore", 3},
  points = 5,
  require = techs_con_req3,
  mode = "activated",
  range = 0,
  cooldown = 14,
  stamina = 20,
  getHeal = function(self, t) return 10 + self:combatTalentStatDamage(t, "con", 10, 350) end,
  getRegeneration = function(self, t) return 4 + self:combatTalentStatDamage(t, "con", 4, 150) end,
  getDuration =  function(self, t) return 4 end,
  getRegenerationTotal = function(self, t) return t.getDuration(self, t) * t.getRegeneration(self, t) end,
	action = function(self, t)
    local critMultiplier = self:physicalCrit(1)
    self:attr("allow_on_heal", 1)
    self:heal(t.getHeal(self, t) * critMultiplier, self)
    self:attr("allow_on_heal", -1)
    
		self:setEffect(self.EFF_WOODCUTTER_REGENERATION, t.getDuration(self, t), {power=(t.getRegenerationTotal(self, t)) / t.getDuration(self, t)})

    if core.shader.active(4) then
      self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true ,size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0}))
      self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false,size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0}))
    end
		game:playSoundNear(self, "talents/heal")
		return true
	end,
  info = function(self, t)
    return ([[You heal for %d, then regenerate %d hp over %d turns.]]):
    tformat(t.getHeal(self, t), t.getRegenerationTotal(self, t), t.getDuration(self, t))
  end
}
newTalent{
  name = "Vitamin Diet", short_name = "WOODCUTTER_VITAMINS",
  image = "talents/woodcutter_vitamins.png",
  type = {"technique/herblore", 4},
  points = 5,
  require = techs_con_req4,
  mode = "passive",
  getSave = function(self, t) return math.floor(self:combatTalentScale(t, 12, 48)) end,
  getSpeedBase = function(self, t)
    if self:getTalentLevel(t) < 5 then return 0 end
    return 0.05
  end,
  -- getSpeedIncrement = function(self, t) return 0.005 end,
  getSpeedTotal = function(self, t)
    local total = t.getSpeedBase(self, t) or 0
    -- -- I'm not sure how to update this, so I'll just ignore it.
    -- if total == 0 then return 0 end
    -- local increment = t.getSpeedIncrement(self, t)
    -- if self.knowTalent and self:knowTalent(self.T_WOODCUTTER_LIGHTWEIGHT_LEAVES) then
    --   local talent = self:getTalentFromId(self.T_WOODCUTTER_LIGHTWEIGHT_LEAVES)
    --   local add = self:getTalentLevelRaw(talent)
    --   total = total + increment * add
    -- end
    -- if self.knowTalent and self:knowTalent(self.T_WOODCUTTER_RESISTANCE_ROOTS) then
    --   local talent = self:getTalentFromId(self.T_WOODCUTTER_RESISTANCE_ROOTS)
    --   local add = self:getTalentLevelRaw(talent)
    --   total = total + increment * add
    -- end
    -- if self.knowTalent and self:knowTalent(self.T_WOODCUTTER_HEALING_HERBS) then
    --   local talent = self:getTalentFromId(self.T_WOODCUTTER_HEALING_HERBS)
    --   local add = self:getTalentLevelRaw(talent)
    --   total = total + increment * add
    -- end
    return total
  end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_physresist", t.getSave(self, t))
		self:talentTemporaryValue(p, "global_speed_add", t.getSpeedTotal(self, t))
	end,
  info = function(self, t)
    return ([[You gain %d physical save. At talent level 5, you gain %0.1f%% global speed.]]):
    -- return ([[You gain %d physical save. At raw level 5, you gain %0.1f%% global speed, increased by %0.1f%% for each talent point spent in other talents of this category (total %0.1f%%).]]):
    tformat( t.getSave(self, t),  100*t.getSpeedTotal(self, t))
    --tformat( t.getSave(self, t),  100*t.getSpeedBase(self, t), 100*t.getSpeedIncrement(self, t), 100*t.getSpeedTotal(self, t))
  end
}